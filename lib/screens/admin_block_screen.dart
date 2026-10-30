import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';

class AdminBlockScreen extends StatefulWidget {
  const AdminBlockScreen({super.key});

  @override
  State<AdminBlockScreen> createState() => _AdminBlockScreenState();
}

class _AdminBlockScreenState extends State<AdminBlockScreen> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  Map<String, dynamic>? _foundUser;
  String? _error;

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _foundUser = null;
      _error = null;
    });

    try {
      final queryLower = query.toLowerCase();
      final allUsersSnap = await FirebaseFirestore.instance.collection('users').get();
      
      QueryDocumentSnapshot? foundDoc;
      for (final doc in allUsersSnap.docs) {
        final data = doc.data();
        final email = (data['email'] ?? '').toString().toLowerCase();
        final phone = (data['phone'] ?? '').toString();
        if (email == queryLower || phone == query) {
          foundDoc = doc;
          break;
        }
      }

      if (foundDoc == null) {
        setState(() {
          _error = 'لم يتم العثور على مستخدم بهذا الإيميل أو الهاتف';
          _searching = false;
        });
        return;
      }

      final doc = foundDoc;
      setState(() {
        _foundUser = {'id': doc.id, ...(doc.data() as Map<String, dynamic>)};
        _searching = false;
      });
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء البحث';
        _searching = false;
      });
    }
  }

  Future<void> _toggleBlock(String userId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isBlocked': !currentStatus,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentStatus ? 'تم إلغاء الحظر' : 'تم حظر المستخدم')),
      );
      if (_foundUser != null && _foundUser!['id'] == userId) {
        setState(() {
          _foundUser!['isBlocked'] = !currentStatus;
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'إدارة الحظر',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- قسم البحث ---
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration:  InputDecoration(
                          hintText: 'ابحث بالإيميل أو الهاتف لحظر مستخدم...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _searching ? null : _search,
                    child: _searching
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
              
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],

              if (_foundUser != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _foundUser!['isBlocked'] == true ? Colors.redAccent : Colors.green),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.accent, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((_foundUser!['name'] ?? 'بدون اسم').toString(),
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                Text((_foundUser!['email'] ?? '').toString(),
                                    style:  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                Text((_foundUser!['phone'] ?? '').toString(),
                                    style:  TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _foundUser!['isBlocked'] == true ? Colors.green : Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _toggleBlock(_foundUser!['id'], _foundUser!['isBlocked'] == true),
                          icon: Icon(_foundUser!['isBlocked'] == true ? Icons.lock_open : Icons.block, color: Colors.white),
                          label: Text(
                            _foundUser!['isBlocked'] == true ? 'إلغاء الحظر' : 'حظر المستخدم',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'قائمة المحظورين (الذين تم حظرهم حالياً):',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // --- لستة المحظورين ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('isBlocked', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('لا يوجد مستخدمون محظورون حالياً.',
                            style: TextStyle(color: Colors.white54, fontSize: 14)),
                      );
                    }

                    final blockedUsers = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: blockedUsers.length,
                      itemBuilder: (context, i) {
                        final data = blockedUsers[i].data() as Map<String, dynamic>;
                        final id = blockedUsers[i].id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.block, color: Colors.redAccent),
                            title: Text((data['name'] ?? 'بدون اسم').toString(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text((data['email'] ?? '').toString(),
                                style:  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            trailing: TextButton(
                              onPressed: () => _toggleBlock(id, true),
                              child: const Text('إلغاء الحظر', style: TextStyle(color: Colors.green)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

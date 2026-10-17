const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// في GitHub Actions كيقرا المفتاح من الـ Secret
// في التيليفون كيقراه من الملف المحلي
let serviceAccount;
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
} else {
  serviceAccount = require('/root/firebase-key/key.json');
}

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

async function cleanupDeletedStores() {
  console.log('Starting cleanup of deleted stores...');
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

  try {
    const snap = await db.collection('stores').where('isDeleted', '==', true).get();
    let deletedCount = 0;

    for (const doc of snap.docs) {
      const data = doc.data();
      const deletedAt = data.deletedAt ? data.deletedAt.toDate() : null;

      if (deletedAt && deletedAt < sevenDaysAgo) {
        await doc.ref.delete();
        console.log(`Deleted store: ${doc.id} (${data.name || 'No name'})`);
        deletedCount++;
      } else {
        console.log(`Store ${doc.id} is still in the 7-day grace period.`);
      }
    }

    console.log(`Cleanup finished. Permanently deleted ${deletedCount} stores.`);
  } catch (e) {
    console.error('Error during cleanup:', e);
  }
}

cleanupDeletedStores();

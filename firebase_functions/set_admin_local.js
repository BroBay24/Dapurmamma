/**
 * Script untuk Set Admin Custom Claim secara lokal
 * 
 * CARA PAKAI:
 * 
 * 1. Download Service Account Key dari Firebase Console:
 *    - Buka: https://console.firebase.google.com/project/cake-mamma-13154/settings/serviceaccounts/adminsdk
 *    - Klik "Generate new private key"
 *    - Simpan file JSON ke folder ini dengan nama: serviceAccountKey.json
 * 
 * 2. Install dependencies:
 *    cd firebase_functions
 *    npm install firebase-admin
 * 
 * 3. Jalankan script:
 *    node set_admin_local.js bayfrd24@gmail.com
 * 
 * 4. PENTING: Hapus serviceAccountKey.json setelah selesai (jangan commit ke git!)
 */

const admin = require('firebase-admin');
const path = require('path');

// Path ke service account key
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');

try {
  const serviceAccount = require(serviceAccountPath);
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} catch (error) {
  console.error('\n❌ Error: serviceAccountKey.json tidak ditemukan!');
  console.log('\nCara mendapatkan Service Account Key:');
  console.log('1. Buka: https://console.firebase.google.com/project/cake-mamma-13154/settings/serviceaccounts/adminsdk');
  console.log('2. Klik "Generate new private key"');
  console.log('3. Simpan file JSON ke folder ini dengan nama: serviceAccountKey.json');
  console.log('4. Jalankan script ini lagi\n');
  process.exit(1);
}

async function setAdminClaim(email) {
  try {
    // Dapatkan user berdasarkan email
    const user = await admin.auth().getUserByEmail(email);
    console.log(`\n✓ User ditemukan: ${user.email} (UID: ${user.uid})`);

    // Set custom claim admin: true
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    console.log(`✓ Custom claim 'admin: true' berhasil diset untuk ${email}`);

    // Verifikasi claim
    const updatedUser = await admin.auth().getUser(user.uid);
    console.log(`✓ Verifikasi claims:`, updatedUser.customClaims);

    console.log('\n🎉 Selesai! User sekarang bisa login ke Admin Panel.');
    console.log('⚠️  PENTING: Hapus file serviceAccountKey.json setelah selesai!\n');
    
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.error(`\n❌ Error: User dengan email ${email} tidak ditemukan.`);
      console.log('Pastikan user sudah terdaftar di Firebase Authentication.\n');
    } else {
      console.error('\n❌ Error:', error.message);
    }
  }

  process.exit(0);
}

// Ambil email dari command line argument
const email = process.argv[2];

if (!email) {
  console.log('\nUsage: node set_admin_local.js <email>');
  console.log('Example: node set_admin_local.js bayfrd24@gmail.com\n');
  process.exit(1);
}

setAdminClaim(email);

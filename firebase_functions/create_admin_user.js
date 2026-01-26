/**
 * Script untuk Membuat User Admin di Firebase Auth
 * 
 * CARA PAKAI:
 * 
 * 1. Download Service Account Key dari Firebase Console:
 *    - Buka: https://console.firebase.google.com/project/cake-mamma-13154/settings/serviceaccounts/adminsdk
 *    - Klik "Generate new private key"
 *    - Simpan file JSON ke folder ini dengan nama: serviceAccountKey.json
 * 
 * 2. Install dependencies (jika belum):
 *    cd firebase_functions
 *    npm install firebase-admin
 * 
 * 3. Jalankan script:
 *    node create_admin_user.js
 * 
 * 4. PENTING: Hapus serviceAccountKey.json setelah selesai (jangan commit ke git!)
 */

const admin = require('firebase-admin');
const path = require('path');

// ================================
// KONFIGURASI ADMIN USER
// ================================
const ADMIN_EMAIL = 'bayfrd24@gmail.com';
const ADMIN_PASSWORD = 'password123';
const ADMIN_DISPLAY_NAME = 'Admin Dapur Mamma';
// ================================

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

async function createAdminUser() {
  console.log('\n========================================');
  console.log('  CREATE ADMIN USER - DAPUR MAMMA');
  console.log('========================================\n');

  try {
    // Cek apakah user sudah ada
    let user;
    try {
      user = await admin.auth().getUserByEmail(ADMIN_EMAIL);
      console.log(`✓ User sudah ada: ${user.email} (UID: ${user.uid})`);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // Buat user baru
        console.log(`Creating new user: ${ADMIN_EMAIL}`);
        user = await admin.auth().createUser({
          email: ADMIN_EMAIL,
          password: ADMIN_PASSWORD,
          displayName: ADMIN_DISPLAY_NAME,
          emailVerified: true, // Set email verified langsung
        });
        console.log(`✓ User berhasil dibuat: ${user.email} (UID: ${user.uid})`);
      } else {
        throw error;
      }
    }

    // Set custom claim admin: true
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });
    console.log(`✓ Custom claim 'admin: true' berhasil di-set`);

    // Verifikasi
    const updatedUser = await admin.auth().getUser(user.uid);
    console.log('\n----------------------------------------');
    console.log('  USER INFO');
    console.log('----------------------------------------');
    console.log(`  Email    : ${updatedUser.email}`);
    console.log(`  Password : ${ADMIN_PASSWORD}`);
    console.log(`  UID      : ${updatedUser.uid}`);
    console.log(`  Name     : ${updatedUser.displayName}`);
    console.log(`  Admin    : ${updatedUser.customClaims?.admin === true ? 'YES ✓' : 'NO'}`);
    console.log('----------------------------------------\n');

    console.log('✅ SELESAI! User admin siap digunakan.');
    console.log('\nSilakan login di aplikasi dengan:');
    console.log(`  Email    : ${ADMIN_EMAIL}`);
    console.log(`  Password : ${ADMIN_PASSWORD}\n`);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    if (error.code) {
      console.error('   Code:', error.code);
    }
  }

  process.exit(0);
}

// Jalankan
createAdminUser();

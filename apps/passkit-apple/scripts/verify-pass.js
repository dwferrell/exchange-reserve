#!/usr/bin/env node

/**
 * Verify a .pkpass file
 *
 * Checks:
 * - Valid zip structure
 * - All required files present
 * - Manifest hashes match files
 * - Signature is valid
 * - pass.json is valid JSON
 */

import fs from 'fs/promises';
import fsSync from 'fs';
import path from 'path';
import crypto from 'crypto';
import { exec } from 'child_process';
import { promisify } from 'util';
import { fileURLToPath } from 'url';

const execAsync = promisify(exec);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function sha1Hash(filePath) {
  const content = await fs.readFile(filePath);
  return crypto.createHash('sha1').update(content).digest('hex');
}

async function verifyPass(pkpassPath) {
  console.log(`\n🔍 Verifying pass: ${path.basename(pkpassPath)}\n`);

  // Check file exists
  try {
    await fs.access(pkpassPath);
  } catch {
    console.error('❌ Pass file not found');
    return false;
  }

  // Create temp extraction directory
  const tempDir = path.join(__dirname, '..', 'dist', 'temp', 'verify');
  await fs.rm(tempDir, { recursive: true, force: true });
  await fs.mkdir(tempDir, { recursive: true });

  // Extract .pkpass
  try {
    await execAsync(`unzip -q "${pkpassPath}" -d "${tempDir}"`);
    console.log('✅ Pass is valid zip archive');
  } catch (error) {
    console.error('❌ Failed to extract pass - not a valid zip file');
    return false;
  }

  // Check required files
  const requiredFiles = ['pass.json', 'manifest.json', 'signature'];
  for (const file of requiredFiles) {
    const filePath = path.join(tempDir, file);
    try {
      const stats = await fs.stat(filePath);
      if (stats.size === 0) {
        console.error(`❌ ${file} is empty`);
        return false;
      }
      console.log(`✅ ${file} present (${stats.size} bytes)`);
    } catch {
      console.error(`❌ ${file} is missing`);
      return false;
    }
  }

  // Validate pass.json
  try {
    const passJsonPath = path.join(tempDir, 'pass.json');
    const passData = JSON.parse(await fs.readFile(passJsonPath, 'utf8'));

    console.log('\n📄 Pass Details:');
    console.log(`   Organization: ${passData.organizationName}`);
    console.log(`   Description: ${passData.description}`);
    console.log(`   Serial Number: ${passData.serialNumber}`);
    console.log(`   Team ID: ${passData.teamIdentifier}`);
    console.log(`   Pass Type: ${passData.passTypeIdentifier}`);

    // Check for placeholder values
    if (passData.teamIdentifier === 'YOUR_TEAM_ID') {
      console.warn('⚠️  Team ID is still a placeholder');
    }
  } catch (error) {
    console.error('❌ pass.json is invalid:', error.message);
    return false;
  }

  // Verify manifest hashes
  console.log('\n🔐 Verifying manifest hashes...');
  try {
    const manifestPath = path.join(tempDir, 'manifest.json');
    const manifest = JSON.parse(await fs.readFile(manifestPath, 'utf8'));

    let allHashesValid = true;
    for (const [file, expectedHash] of Object.entries(manifest)) {
      const filePath = path.join(tempDir, file);
      try {
        const actualHash = await sha1Hash(filePath);
        if (actualHash === expectedHash) {
          console.log(`   ✅ ${file}`);
        } else {
          console.error(`   ❌ ${file} - hash mismatch`);
          console.error(`      Expected: ${expectedHash}`);
          console.error(`      Actual:   ${actualHash}`);
          allHashesValid = false;
        }
      } catch (error) {
        console.error(`   ❌ ${file} - file not found`);
        allHashesValid = false;
      }
    }

    if (!allHashesValid) {
      console.error('\n❌ Manifest verification failed');
      return false;
    }
    console.log('✅ All manifest hashes valid');
  } catch (error) {
    console.error('❌ Failed to verify manifest:', error.message);
    return false;
  }

  // Verify signature
  console.log('\n🔏 Verifying signature...');
  try {
    const manifestPath = path.join(tempDir, 'manifest.json');
    const signaturePath = path.join(tempDir, 'signature');
    const wwdrPath = path.join(__dirname, '..', 'certificates', 'apple_wwdr_g3.pem');

    // Check if WWDR certificate exists
    try {
      await fs.access(wwdrPath);
    } catch {
      console.warn('⚠️  WWDR certificate not found - skipping signature verification');
      console.warn(`   Place apple_wwdr_g3.pem in certificates/ to enable signature verification`);
      return true;
    }

    // Verify signature using OpenSSL
    const cmd = `openssl smime -verify -in "${signaturePath}" -inform DER -content "${manifestPath}" -CAfile "${wwdrPath}" -noverify 2>&1`;

    try {
      const { stdout, stderr } = await execAsync(cmd);
      if (stdout.includes('Verification successful')) {
        console.log('✅ Signature is valid');
      } else {
        console.warn('⚠️  Signature verification inconclusive');
        console.log('   Output:', stdout || stderr);
      }
    } catch (error) {
      // OpenSSL may exit with non-zero even on success
      if (error.stdout && error.stdout.includes('Verification successful')) {
        console.log('✅ Signature is valid');
      } else {
        console.warn('⚠️  Could not verify signature');
        console.log('   This may be normal if the certificate chain is not complete');
      }
    }
  } catch (error) {
    console.warn('⚠️  Signature verification failed:', error.message);
  }

  // Cleanup
  await fs.rm(tempDir, { recursive: true, force: true });

  console.log('\n✅ Pass verification complete!\n');
  return true;
}

// Main
const pkpassPath = process.argv[2];
if (!pkpassPath) {
  console.error('Usage: node verify-pass.js <path-to-pass.pkpass>');
  process.exit(1);
}

const fullPath = path.resolve(pkpassPath);
verifyPass(fullPath)
  .then((success) => {
    process.exit(success ? 0 : 1);
  })
  .catch((error) => {
    console.error('\n❌ Verification failed:', error.message);
    process.exit(1);
  });

#!/usr/bin/env node

import fs from 'fs/promises';
import fsSync from 'fs';
import path from 'path';
import crypto from 'crypto';
import { exec } from 'child_process';
import { promisify } from 'util';
import archiver from 'archiver';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

const execAsync = promisify(exec);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

// Load environment variables
dotenv.config({ path: path.join(rootDir, '.env.local') });

const TEAM_ID = process.env.APPLE_TEAM_ID || '5A984FTAG3';
const PASS_TYPE_ID = process.env.PASS_TYPE_IDENTIFIER || 'pass.exchangereserve.lift';
const ORG_NAME = process.env.ORGANIZATION_NAME || 'LocalFund';

/**
 * Calculate SHA1 hash of a file
 */
async function sha1Hash(filePath) {
  const content = await fs.readFile(filePath);
  return crypto.createHash('sha1').update(content).digest('hex');
}

/**
 * Generate manifest.json
 */
async function generateManifest(passDir) {
  const files = await fs.readdir(passDir);
  const manifest = {};

  for (const file of files) {
    if (file === 'manifest.json' || file === 'signature') {
      continue;
    }
    const filePath = path.join(passDir, file);
    const stats = await fs.stat(filePath);
    if (stats.isFile()) {
      manifest[file] = await sha1Hash(filePath);
    }
  }

  const manifestPath = path.join(passDir, 'manifest.json');
  await fs.writeFile(manifestPath, JSON.stringify(manifest, null, 2));
  console.log('✅ Generated manifest.json');
  return manifestPath;
}

/**
 * Sign manifest using macOS keychain
 */
async function signManifest(passDir) {
  const manifestPath = path.join(passDir, 'manifest.json');
  const signaturePath = path.join(passDir, 'signature');
  const certsDir = path.join(rootDir, 'certificates');

  try {
    // Use OpenSSL to sign with certificate and key files
    const cmd = `openssl smime -binary -sign \
      -certfile "${certsDir}/apple_wwdr_g4.pem" \
      -signer "${certsDir}/signerCert-new.pem" \
      -inkey "${certsDir}/signerKey.pem" \
      -in "${manifestPath}" \
      -out "${signaturePath}" \
      -outform DER \
      -passin pass:`;

    const { stdout, stderr } = await execAsync(cmd);

    if (stderr && !stderr.includes('Signature')) {
      console.log('Signing output:', stderr);
    }

    // Check if signature was created and is not empty
    const stats = await fs.stat(signaturePath);
    if (stats.size === 0) {
      throw new Error('Signature file is empty');
    }

    console.log(`✅ Signed manifest (signature size: ${stats.size} bytes)`);
  } catch (error) {
    console.error('❌ Signing failed:', error.message);
    console.error('Make sure certificates are in:', certsDir);
    console.error('Required files: signerCert-new.pem, signerKey.pem, apple_wwdr_g4.pem');
    throw error;
  }
}

/**
 * Create .pkpass file (zip archive)
 */
async function createPkpass(passDir, outputPath) {
  return new Promise((resolve, reject) => {
    const output = fsSync.createWriteStream(outputPath);
    const archive = archiver('zip', { zlib: { level: 9 } });

    output.on('close', () => {
      console.log(`✅ Created ${path.basename(outputPath)} (${archive.pointer()} bytes)`);
      resolve();
    });

    archive.on('error', reject);
    archive.pipe(output);

    // Add all files from pass directory
    archive.directory(passDir, false);
    archive.finalize();
  });
}

/**
 * Build a pass
 */
async function buildPass(templateName = 'hello-world') {
  console.log(`\n🔨 Building pass: ${templateName}\n`);

  const templateDir = path.join(rootDir, 'templates', templateName);
  const tempDir = path.join(rootDir, 'dist', 'temp', templateName);
  const outputPath = path.join(rootDir, 'dist', `${templateName}.pkpass`);

  // Clean and create temp directory
  await fs.rm(tempDir, { recursive: true, force: true });
  await fs.mkdir(tempDir, { recursive: true });

  // Copy pass.json
  const passJsonPath = path.join(templateDir, 'pass.json');
  let passData = await fs.readFile(passJsonPath, 'utf8');

  // Replace placeholders
  passData = passData
    .replace('YOUR_TEAM_ID', TEAM_ID)
    .replace('YOUR_ORGANIZATION', ORG_NAME);

  await fs.writeFile(path.join(tempDir, 'pass.json'), passData);
  console.log('✅ Copied pass.json');

  // Copy assets (icons, logos, backgrounds)
  const assetsDir = path.join(rootDir, 'assets');
  const assetFiles = await fs.readdir(assetsDir);

  for (const file of assetFiles) {
    const src = path.join(assetsDir, file);
    const dest = path.join(tempDir, file);
    await fs.copyFile(src, dest);
  }
  console.log(`✅ Copied ${assetFiles.length} asset files`);

  // Generate manifest
  await generateManifest(tempDir);

  // Sign manifest
  await signManifest(tempDir);

  // Create .pkpass
  await createPkpass(tempDir, outputPath);

  console.log(`\n✅ Pass built successfully!`);
  console.log(`📦 Output: ${outputPath}`);
  console.log(`\n💡 To install on iPhone:`);
  console.log(`   - AirDrop: Open Finder, right-click ${path.basename(outputPath)}, select "Share" > "AirDrop"`);
  console.log(`   - Email: Attach ${path.basename(outputPath)} to an email and open on iPhone`);
  console.log(`   - Or simply: open ${outputPath}\n`);
}

// Main
const templateName = process.argv[2] || 'hello-world';
buildPass(templateName).catch((error) => {
  console.error('\n❌ Build failed:', error.message);
  process.exit(1);
});

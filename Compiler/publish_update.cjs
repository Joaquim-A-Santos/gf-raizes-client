const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execSync } = require('child_process');

// Configuration
const SOURCE_DIR = path.resolve(__dirname, '..'); // Parent folder (ArquivosDoCliente)
const OUTPUT_FILE = path.join(SOURCE_DIR, 'manifest.json');
const COMPILER_DIR_NAME = path.basename(__dirname); // Name of this folder (Compiler)

const IGNORE_FILES = [
    'manifest.json',
    'client.ini',
    'gf-raizes.exe',
    'Launcher.exe',
    '.git',
    '.DS_Store',
    'Thumbs.db',
    'desktop.ini',
	'Compiler.zip',
    COMPILER_DIR_NAME // Ignore the compiler folder itself
];

const IGNORE_EXTENSIONS = [
    '.pdb',
    '.log',
    '.tmp'
];

function getFileHash(filePath) {
    const fileBuffer = fs.readFileSync(filePath);
    const hashSum = crypto.createHash('sha256');
    hashSum.update(fileBuffer);
    return hashSum.digest('hex');
}

function shouldIgnore(entryPath, entryName) {
    if (IGNORE_FILES.includes(entryName)) return true;
    if (IGNORE_EXTENSIONS.some(ext => entryName.endsWith(ext))) return true;
    if (entryName.startsWith('.')) return true;
    return false;
}

function scanDirectory(dir, baseDir) {
    let results = [];
    let list;
    try {
        list = fs.readdirSync(dir);
    } catch (e) {
        console.error(`Error reading directory ${dir}:`, e);
        return [];
    }
    
    list.forEach(file => {
        const filePath = path.join(dir, file);
        let stat;
        try {
            stat = fs.statSync(filePath);
        } catch (e) {
            console.error(`Error stating file ${filePath}:`, e);
            return;
        }
        
        if (shouldIgnore(filePath, file)) return;

        if (stat && stat.isDirectory()) {
            results = results.concat(scanDirectory(filePath, baseDir));
        } else {
            const relativePath = path.relative(baseDir, filePath).replace(/\\/g, '/');
            console.log(`Processing: ${relativePath}`);
            
            results.push({
                path: relativePath,
                hash: getFileHash(filePath),
                size: stat.size
            });
        }
    });
    
    return results;
}

// 1. Generate Manifest
console.log('--- Step 1: Generating Manifest ---');
console.log(`Scanning directory: ${SOURCE_DIR}`);

if (!fs.existsSync(SOURCE_DIR)) {
    console.error(`Error: Directory '${SOURCE_DIR}' not found!`);
    process.exit(1);
}

const files = scanDirectory(SOURCE_DIR, SOURCE_DIR);

const manifest = {
    files: files
};

fs.writeFileSync(OUTPUT_FILE, JSON.stringify(manifest, null, 2));
console.log(`Manifest generated with ${files.length} files at ${OUTPUT_FILE}`);

// 2. Git Operations
console.log('\n--- Step 2: Git Operations ---');

try {
    // Check if git is available
    execSync('git --version', { stdio: 'ignore' });
    
    // Check if inside a git repo
    process.chdir(SOURCE_DIR);
    execSync('git rev-parse --is-inside-work-tree', { stdio: 'ignore' });
    
    // Check status
    const status = execSync('git status --porcelain').toString();
    if (!status && files.length > 0) {
        console.log('No changes detected in Git.');
        // Even if no file changes, manifest might have updated? 
        // If manifest updated, git status would show it.
        // If status is empty, really nothing changed.
    } else {
        console.log('Changes detected. Preparing commit...');
        
        // Add all files
        console.log('Adding files...');
        execSync('git add .');
        
        // Generate Commit Message
        const date = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
        const shortHash = crypto.createHash('sha256').update(JSON.stringify(manifest)).digest('hex').substring(0, 8);
        const commitMsg = `Auto Update [${shortHash}] - ${date}`;
        
        // Commit
        console.log(`Committing: "${commitMsg}"`);
        execSync(`git commit -m "${commitMsg}"`);
        
        // Push
        console.log('Pushing to remote...');
        execSync('git push');
        
        console.log('Successfully pushed updates!');
    }

} catch (error) {
    console.error('Git operation failed:', error.message);
    if (error.stdout) console.log(error.stdout.toString());
    if (error.stderr) console.error(error.stderr.toString());
    
    console.log('\nMake sure you have Git installed and configured with access rights to the repository.');
}

console.log('\nDone.');

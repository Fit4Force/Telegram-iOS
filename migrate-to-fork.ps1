# Telegram iOS Contest - Fork Migration Script
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Telegram iOS Contest Fork Migration ===" -ForegroundColor Cyan
Write-Host "Organization: Fit4Force" -ForegroundColor Yellow
Write-Host "Target Fork: Telegram-iOS" -ForegroundColor Yellow
Write-Host ""

# Step 1: Check if fork exists
Write-Host "[1/6] Checking fork status..." -ForegroundColor Green
$forkUrl = "https://github.com/Fit4Force/Telegram-iOS"
$forkCheck = $null
try {
    $forkCheck = Invoke-WebRequest -Uri $forkUrl -Method Head -ErrorAction SilentlyContinue -TimeoutSec 5
} catch {
    # Fork doesn't exist
}

if (-not $forkCheck -or $forkCheck.StatusCode -ne 200) {
    Write-Host ""
    Write-Host "FORK NOT FOUND!" -ForegroundColor Red
    Write-Host "Please create the fork first:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/TelegramMessenger/Telegram-iOS"
    Write-Host "2. Click 'Fork' button"
    Write-Host "3. Select organization: Fit4Force"
    Write-Host "4. Name it EXACTLY: Telegram-iOS"
    Write-Host "5. Keep it PUBLIC"
    Write-Host "6. Click 'Create fork'"
    Write-Host ""
    Write-Host "Press Enter after creating the fork..." -ForegroundColor Cyan
    Read-Host
}

# Step 2: Configure git remote
Write-Host "[2/6] Configuring git remotes..." -ForegroundColor Green
$currentRemote = git remote get-url origin 2>$null

if ($currentRemote -ne "https://github.com/Fit4Force/Telegram-iOS.git") {
    $hasForkRemote = git remote | Select-String -Pattern "^fork$"
    if ($hasForkRemote) {
        git remote remove fork
    }
    git remote add fork https://github.com/Fit4Force/Telegram-iOS.git
    Write-Host "Added fork remote" -ForegroundColor Yellow
} else {
    Write-Host "Already pointing to fork" -ForegroundColor Yellow
}

# Step 3: Stage all changes
Write-Host "[3/6] Staging all contest changes..." -ForegroundColor Green
git add -A
$changedFiles = git diff --cached --name-only
$fileCount = ($changedFiles | Measure-Object).Count
Write-Host "Staged $fileCount files" -ForegroundColor Yellow

# Step 4: Commit changes
Write-Host "[4/6] Creating contest submission commit..." -ForegroundColor Green
$commitMsg = "iOS Contest 2025: Frosted Glass UI and Enhanced Chat Interface

Contest Submission - Telegram iOS Design Competition 2025

Features Implemented:
- Frosted glass blur effects throughout the app
- Enhanced navigation bars with dynamic glass backgrounds  
- Improved chat list visual hierarchy
- Custom GlassBackgroundView with configurable blur
- BlurredBackgroundView for entity keyboard and panels
- LiquidGlass effect components for modern UI

Technical Improvements:
- Fixed disabled code blocks in navigation bar centering
- Enabled entity keyboard background initialization
- Optimized blur rendering with custom radius control
- Enhanced visual consistency across components

Organization: Fit4Force
Repository: Telegram-iOS
Submission Date: December 26, 2025"

git commit -m $commitMsg
$commitHash = git rev-parse HEAD
Write-Host "Commit created: $commitHash" -ForegroundColor Yellow

# Step 5: Push to fork
Write-Host "[5/6] Pushing to Fit4Force/Telegram-iOS fork..." -ForegroundColor Green
$currentBranch = git branch --show-current

if ($currentRemote -eq "https://github.com/Fit4Force/Telegram-iOS.git") {
    git push origin $currentBranch -f
    $remoteName = "origin"
} else {
    git push fork $currentBranch -f
    $remoteName = "fork"
}
Write-Host "Pushed to $remoteName/$currentBranch" -ForegroundColor Yellow

# Step 6: Generate submission URL
Write-Host ""
Write-Host "[6/6] Generating contest submission URL..." -ForegroundColor Green
$submissionUrl = "https://github.com/Fit4Force/Telegram-iOS/commit/$commitHash"

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "    CONTEST SUBMISSION READY" -ForegroundColor Cyan  
Write-Host "================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Your Commit URL:" -ForegroundColor Green
Write-Host $submissionUrl -ForegroundColor White

$submissionUrl | Set-Clipboard
Write-Host ""
Write-Host "URL copied to clipboard!" -ForegroundColor Yellow

Write-Host ""
Write-Host "Verification:" -ForegroundColor Cyan
Write-Host "  Repository: Fit4Force/Telegram-iOS" -ForegroundColor Green
Write-Host "  Commit: $commitHash" -ForegroundColor Green
Write-Host "  Branch: $currentBranch" -ForegroundColor Green
Write-Host "  Files: $fileCount" -ForegroundColor Green

Write-Host ""
Write-Host "Open in browser? (Y/N): " -ForegroundColor Cyan -NoNewline
$openBrowser = Read-Host
if ($openBrowser -eq 'Y' -or $openBrowser -eq 'y') {
    Start-Process $submissionUrl
}

Write-Host ""
Write-Host "Migration Complete!" -ForegroundColor Green
Write-Host "Submit URL:" -ForegroundColor Yellow
Write-Host $submissionUrl -ForegroundColor White

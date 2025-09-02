# GitHub Branch Protection Setup

This document explains how to configure GitHub branch protection rules to ensure only the `dev` branch can be merged into `main`.

## Method 1: GitHub UI Configuration (Recommended)

### Step 1: Access Repository Settings
1. Navigate to your repository on GitHub
2. Click on **Settings** tab
3. Select **Branches** from the left sidebar

### Step 2: Add Branch Protection Rule
1. Click **Add rule** button
2. In **Branch name pattern**, enter: `main`
3. Configure the following settings:

#### Required Settings:
- ✅ **Restrict pushes that create files**
- ✅ **Require pull request reviews before merging**
- ✅ **Require status checks to pass before merging**
- ✅ **Require branches to be up to date before merging**
- ✅ **Restrict who can push to matching branches**

#### Advanced Settings:
- ✅ **Include administrators** (optional, but recommended)
- ✅ **Allow force pushes** → **Specify who can force push** → Select **Everyone** and then restrict to specific users/teams if needed

### Step 3: Configure Source Branch Restrictions
In the **Restrict pushes that create files** section:
1. Select **Restrict pushes that create files**
2. Add exception: `dev` branch only
3. This ensures only merges from `dev` are allowed

## Method 2: Automated Enforcement via GitHub Actions

This repository includes a GitHub Actions workflow that automatically validates pull request sources. See `.github/workflows/branch-protection.yml` for implementation details.

## Method 3: GitHub API Configuration

Use the provided script `scripts/setup-branch-protection.js` to configure branch protection programmatically.

### Prerequisites:
- Node.js installed
- GitHub Personal Access Token with `repo` permissions
- Repository admin access

### Usage:
```bash
cd scripts
npm install
GITHUB_TOKEN=your_token_here node setup-branch-protection.js
```

## Verification

After setting up branch protection:

1. **Test Direct Push Blocking**: Try pushing directly to `main` - should be rejected
2. **Test Dev Merge**: Create PR from `dev` to `main` - should be allowed
3. **Test Other Branch Merge**: Create PR from any other branch to `main` - should be blocked

## Branch Workflow

The recommended workflow with these protections:

```
feature/xyz → dev → main
     ↓         ↓      ↓
   develop  →  test →  production
```

1. Create feature branches from `dev`
2. Merge feature branches into `dev` via pull request
3. Merge `dev` into `main` via pull request (only allowed merge path)
4. Deploy from `main` branch

## Troubleshooting

### Common Issues:

**Problem**: Can't merge dev to main
- **Solution**: Ensure all required status checks pass
- **Solution**: Ensure pull request has required reviews

**Problem**: Accidentally committed to main
- **Solution**: Create a new branch from main, reset main to previous commit (requires admin override)

**Problem**: Need hotfix on main
- **Solution**: Create hotfix branch from main, merge to main AND dev to keep branches in sync

### Emergency Procedures:

If immediate access to main is required:
1. Temporarily disable branch protection (admin required)
2. Make necessary changes
3. Re-enable branch protection
4. Ensure dev branch is updated with main changes

## Additional Resources

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub API Branch Protection](https://docs.github.com/en/rest/branches/branch-protection)
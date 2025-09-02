# Branch Protection Scripts

This directory contains automation scripts for setting up GitHub branch protection rules.

## Quick Start

### 1. Install Dependencies
```bash
cd scripts
npm install
```

### 2. Configure Environment
```bash
cp .env.example .env
# Edit .env and add your GitHub token
```

### 3. Run Setup Script
```bash
npm run setup
```

## What the Script Does

The `setup-branch-protection.js` script:

1. **Verifies repository access** - Confirms you have admin permissions
2. **Creates required branches** - Creates `main` and `dev` branches if they don't exist
3. **Configures branch protection** - Sets up protection rules for the `main` branch
4. **Validates setup** - Confirms all rules are applied correctly

### Branch Protection Rules Applied:

- ✅ **Required status checks**: `enforce-branch-protection` (from GitHub Actions)
- ✅ **Required pull request reviews**: Minimum 1 approval
- ✅ **Dismiss stale reviews**: When new commits are pushed
- ✅ **Up-to-date branches**: PRs must be current with target branch
- ✅ **Enforce for administrators**: Even admins follow the rules
- ❌ **Force pushes**: Disabled for safety
- ❌ **Branch deletions**: Disabled for safety

## GitHub Token Setup

### 1. Generate Personal Access Token
1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select the following permissions:
   - `repo` (Full control of private repositories)
   - `admin:repo_hook` (Admin access to repository hooks)

### 2. Repository Permissions
You must have **admin access** to the repository to set up branch protection rules.

## Manual Verification

After running the script, verify the setup:

### Via GitHub UI:
1. Go to repository **Settings** > **Branches**
2. Confirm protection rule exists for `main` branch
3. Review applied restrictions

### Via Testing:
1. Create a test branch from `main`
2. Try to create PR directly to `main` - should be blocked
3. Create PR from `dev` to `main` - should be allowed

## Troubleshooting

### Common Issues:

**Error: 401 Unauthorized**
- Check your GitHub token has correct permissions
- Verify token is not expired

**Error: 403 Forbidden**
- Ensure you have admin access to the repository
- Check if organization has additional restrictions

**Error: 404 Not Found**
- Verify repository owner and name are correct
- Check if repository exists and you have access

### Debug Mode:
Add `DEBUG=1` environment variable for verbose output:
```bash
DEBUG=1 npm run setup
```

## Integration with CI/CD

The script is designed to work with:
- **GitHub Actions**: `.github/workflows/branch-protection.yml`
- **Manual Setup**: Repository Settings > Branches
- **API Integration**: Other automation tools

## Security Considerations

- 🔒 **Token Security**: Never commit `.env` file to repository
- 👥 **Team Access**: Ensure team members understand the new workflow
- 🚨 **Emergency Access**: Document procedure for emergency main branch access
- 📋 **Compliance**: May need adjustment for regulatory requirements

## Updates and Maintenance

The script is idempotent - safe to run multiple times. Use it to:
- Update branch protection rules
- Apply rules to new repositories
- Verify current configuration
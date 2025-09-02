#!/usr/bin/env node

const { Octokit } = require('@octokit/rest');
require('dotenv').config();

// Configuration
const REPO_OWNER = 'KegenGuyll';
const REPO_NAME = 'Apprenticeship';
const PROTECTED_BRANCH = 'main';
const ALLOWED_SOURCE_BRANCH = 'dev';

async function setupBranchProtection() {
  // Initialize Octokit with token
  const token = process.env.GITHUB_TOKEN;
  
  if (!token) {
    console.error('❌ Error: GITHUB_TOKEN environment variable is required');
    console.log('Usage: GITHUB_TOKEN=your_token_here npm run setup');
    process.exit(1);
  }

  const octokit = new Octokit({
    auth: token
  });

  try {
    console.log(`🔧 Setting up branch protection for ${REPO_OWNER}/${REPO_NAME}...`);
    
    // Check if repository exists and we have access
    await octokit.rest.repos.get({
      owner: REPO_OWNER,
      repo: REPO_NAME
    });
    console.log('✅ Repository access confirmed');

    // Check if main branch exists
    try {
      await octokit.rest.repos.getBranch({
        owner: REPO_OWNER,
        repo: REPO_NAME,
        branch: PROTECTED_BRANCH
      });
      console.log(`✅ Branch '${PROTECTED_BRANCH}' exists`);
    } catch (error) {
      if (error.status === 404) {
        console.log(`⚠️  Branch '${PROTECTED_BRANCH}' does not exist. Creating it...`);
        
        // Get default branch reference
        const repo = await octokit.rest.repos.get({
          owner: REPO_OWNER,
          repo: REPO_NAME
        });
        
        const defaultBranch = repo.data.default_branch;
        const defaultBranchRef = await octokit.rest.git.getRef({
          owner: REPO_OWNER,
          repo: REPO_NAME,
          ref: `heads/${defaultBranch}`
        });

        // Create main branch from default branch
        await octokit.rest.git.createRef({
          owner: REPO_OWNER,
          repo: REPO_NAME,
          ref: `refs/heads/${PROTECTED_BRANCH}`,
          sha: defaultBranchRef.data.object.sha
        });
        console.log(`✅ Created '${PROTECTED_BRANCH}' branch`);
      } else {
        throw error;
      }
    }

    // Check if dev branch exists, create if not
    try {
      await octokit.rest.repos.getBranch({
        owner: REPO_OWNER,
        repo: REPO_NAME,
        branch: ALLOWED_SOURCE_BRANCH
      });
      console.log(`✅ Branch '${ALLOWED_SOURCE_BRANCH}' exists`);
    } catch (error) {
      if (error.status === 404) {
        console.log(`⚠️  Branch '${ALLOWED_SOURCE_BRANCH}' does not exist. Creating it...`);
        
        // Get main branch reference
        const mainBranchRef = await octokit.rest.git.getRef({
          owner: REPO_OWNER,
          repo: REPO_NAME,
          ref: `heads/${PROTECTED_BRANCH}`
        });

        // Create dev branch from main branch
        await octokit.rest.git.createRef({
          owner: REPO_OWNER,
          repo: REPO_NAME,
          ref: `refs/heads/${ALLOWED_SOURCE_BRANCH}`,
          sha: mainBranchRef.data.object.sha
        });
        console.log(`✅ Created '${ALLOWED_SOURCE_BRANCH}' branch`);
      } else {
        throw error;
      }
    }

    // Set up branch protection rule
    const protectionConfig = {
      owner: REPO_OWNER,
      repo: REPO_NAME,
      branch: PROTECTED_BRANCH,
      required_status_checks: {
        strict: true,
        contexts: ['enforce-branch-protection']
      },
      enforce_admins: true,
      required_pull_request_reviews: {
        required_approving_review_count: 1,
        dismiss_stale_reviews: true,
        require_code_owner_reviews: false
      },
      restrictions: null, // Allow all users to create PRs, but enforce via status checks
      allow_force_pushes: false,
      allow_deletions: false
    };

    await octokit.rest.repos.updateBranchProtection(protectionConfig);
    console.log(`✅ Branch protection rule applied to '${PROTECTED_BRANCH}' branch`);

    console.log('\n🎉 Branch protection setup completed successfully!');
    console.log(`\n📋 Summary:`);
    console.log(`   • Protected branch: ${PROTECTED_BRANCH}`);
    console.log(`   • Allowed source branch: ${ALLOWED_SOURCE_BRANCH}`);
    console.log(`   • Required status checks: enforce-branch-protection`);
    console.log(`   • Required pull request reviews: 1`);
    console.log(`   • Force pushes: disabled`);
    console.log(`   • Branch deletions: disabled`);
    
    console.log(`\n🔗 Next steps:`);
    console.log(`   1. Ensure the 'Branch Protection Enforcement' GitHub Action is enabled`);
    console.log(`   2. Test the protection by creating a PR from a non-dev branch`);
    console.log(`   3. Verify dev → main merges work correctly`);

  } catch (error) {
    console.error('❌ Error setting up branch protection:', error.message);
    
    if (error.status === 401) {
      console.log('💡 Tip: Make sure your GitHub token has sufficient permissions (repo scope)');
    } else if (error.status === 403) {
      console.log('💡 Tip: Make sure you have admin permissions on the repository');
    }
    
    process.exit(1);
  }
}

// Run the script
if (require.main === module) {
  setupBranchProtection();
}

module.exports = { setupBranchProtection };
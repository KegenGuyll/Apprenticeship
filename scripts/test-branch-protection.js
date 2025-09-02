#!/usr/bin/env node

/**
 * Test script to validate branch protection logic
 * This simulates the GitHub Actions workflow behavior
 */

function testBranchProtection(sourceBranch, targetBranch) {
  console.log(`\n🧪 Testing: ${sourceBranch} → ${targetBranch}`);
  
  // This mirrors the logic in .github/workflows/branch-protection.yml
  if (targetBranch === 'main' && sourceBranch !== 'dev') {
    console.log('❌ BLOCKED: Pull requests to main branch are only allowed from dev branch.');
    console.log(`   Current source: ${sourceBranch}`);
    console.log(`   Required source: dev`);
    return false;
  } else if (targetBranch === 'main' && sourceBranch === 'dev') {
    console.log('✅ ALLOWED: Pull request from dev branch to main is permitted.');
    return true;
  } else {
    console.log('✅ ALLOWED: Pull request to non-main branch is permitted.');
    return true;
  }
}

// Test scenarios
console.log('=== Branch Protection Logic Test ===');

const testCases = [
  { source: 'dev', target: 'main', expected: true },
  { source: 'feature/user-auth', target: 'main', expected: false },
  { source: 'hotfix/critical-bug', target: 'main', expected: false },
  { source: 'bugfix/issue-123', target: 'main', expected: false },
  { source: 'feature/user-auth', target: 'dev', expected: true },
  { source: 'hotfix/critical-bug', target: 'dev', expected: true },
  { source: 'main', target: 'dev', expected: true },
];

let passed = 0;
let failed = 0;

testCases.forEach((testCase, index) => {
  const result = testBranchProtection(testCase.source, testCase.target);
  const success = result === testCase.expected;
  
  if (success) {
    passed++;
    console.log(`   ✅ Test ${index + 1} PASSED`);
  } else {
    failed++;
    console.log(`   ❌ Test ${index + 1} FAILED - Expected: ${testCase.expected}, Got: ${result}`);
  }
});

console.log(`\n=== Test Results ===`);
console.log(`✅ Passed: ${passed}`);
console.log(`❌ Failed: ${failed}`);
console.log(`📊 Total: ${testCases.length}`);

if (failed === 0) {
  console.log('\n🎉 All tests passed! Branch protection logic is working correctly.');
  process.exit(0);
} else {
  console.log('\n💥 Some tests failed. Please review the protection logic.');
  process.exit(1);
}
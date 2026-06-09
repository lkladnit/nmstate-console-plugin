#!/usr/bin/env bash

set -x
set +e

PROBLEM_DIR="problem"
TOTAL_RUNS=10
PASS_COUNT=0
FAIL_COUNT=0

mkdir -p "${PROBLEM_DIR}"

for i in $(seq -w 1 ${TOTAL_RUNS}); do
  echo "========================================"
  echo "  RUN ${i} of ${TOTAL_RUNS}"
  echo "========================================"

  rm -rf ui-tests-cy/gui-test-screenshots/*

  ./test-cypress.sh
  exit_code=$?

  if [ ${exit_code} -ne 0 ]; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
    RUN_DIR="${PROBLEM_DIR}/run${i}"
    mkdir -p "${RUN_DIR}"

    if [ -d "ui-tests-cy/gui-test-screenshots/screenshots" ]; then
      cp -r ui-tests-cy/gui-test-screenshots/screenshots "${RUN_DIR}/"
    fi
    if [ -d "ui-tests-cy/gui-test-screenshots/videos" ]; then
      cp -r ui-tests-cy/gui-test-screenshots/videos "${RUN_DIR}/"
    fi
    if [ -f "ui-tests-cy/gui-test-screenshots/build.log" ]; then
      cp ui-tests-cy/gui-test-screenshots/build.log "${RUN_DIR}/"
    fi

    echo "  -> FAILED (evidence saved to ${RUN_DIR}/)"
  else
    PASS_COUNT=$((PASS_COUNT + 1))
    echo "  -> PASSED"
  fi
done

echo ""
echo "========================================"
echo "  RESULTS: ${PASS_COUNT} passed, ${FAIL_COUNT} failed out of ${TOTAL_RUNS} runs"
echo "========================================"

cat > "${PROBLEM_DIR}/summary.md" <<SUMMARY
# NMState E2E Flakiness Research — Summary

## Results

- **Total runs:** ${TOTAL_RUNS}
- **Passed:** ${PASS_COUNT}
- **Failed:** ${FAIL_COUNT}
- **Failure rate:** $((FAIL_COUNT * 100 / TOTAL_RUNS))%

## Evidence

Each \`runXX/\` folder contains:
- \`screenshots/\` — failure screenshots
- \`videos/\` — full test recording
- \`build.log\` — Cypress console output

SUMMARY

echo "Summary written to ${PROBLEM_DIR}/summary.md"

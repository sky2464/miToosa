# Project Domain Language - CI/CD and Automation

**PR Validation**: A highly optimized, lightweight, zero-cost GitHub Actions pipeline that runs on every Pull Request targeting `main`. Executed in `.github/workflows/pr-validation.yml`. Not: "CI build", "nightly build".

**Actions Caching**: The process of caching dependency packages (e.g. Flutter/Pub caches) within GitHub Actions runners to minimize execution time. Maps to `subosito/flutter-action` cache configuration. Not: "runner pre-install", "virtual environment storage".

**Local Deployment**: Manual execution of the deployment script (`scripts/deploy-staging.sh`) from a local development environment. Protects sensitive Firebase deployment keys by keeping them out of CI environments. Not: "CI/CD deployment", "auto-deploy".

**Path-Filtered Execution**: Conditional step execution in a workflow based on whether files in a specific directory have changed in the current commit or pull request. Maps to GitHub Action `on.pull_request.paths` or script-level diff evaluation. Not: "scheduled check", "blanket run".

**Prompt Injection Guard**: A local or pipeline-level regression script (`scripts/check_prompt_injection.sh`) that regex-scans documentation for unsafe agent directives. Not: "jailbreak filter", "runtime injection scanner".

**Docs Archival**: The system policy and script (`scripts/verify_docs_archival.sh`) that verifies all completed executable specifications are correctly moved to `docs/archived/` before code changes are shipped. Not: "spec backup", "clean-up cron".

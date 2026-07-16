from pathlib import Path
import json

root = Path(__file__).resolve().parents[1]
required = [
    'README.md', 'AGENTS.md', 'PROJECT_MANIFEST.yaml', 'PROGRESS.md',
    'docs/03_SCHEDULE_ENGINE.md', 'docs/07_UI_UX_SPEC.md',
    'codex/MASTER_PROMPT.md', 'codex/00_BOOTSTRAP.md',
    'ui/UI_REFERENCE_FULL.png', 'config/design_tokens.json'
]
missing = [p for p in required if not (root / p).exists()]
if missing:
    raise SystemExit(f'Missing files: {missing}')
json.loads((root / 'config/design_tokens.json').read_text(encoding='utf-8'))
json.loads((root / 'config/sample_schedule.json').read_text(encoding='utf-8'))
print('Package validation passed.')

#!/usr/bin/env bash
# setup-local.sh — creates required local config files that are not tracked by Git.
# Run once after cloning: bash scripts/setup-local.sh

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

created=0

# ── .firebaserc ────────────────────────────────────────────────────────────────
if [ ! -f ".firebaserc" ]; then
  cat > .firebaserc << 'EOF'
{
  "projects": {
    "default": "black-river-market"
  },
  "targets": {},
  "etags": {}
}
EOF
  echo "  created  .firebaserc"
  created=1
else
  echo "  exists   .firebaserc"
fi

# ── firebase.json ──────────────────────────────────────────────────────────────
if [ ! -f "firebase.json" ]; then
  cat > firebase.json << 'EOF'
{
  "functions": {
    "source": "functions",
    "runtime": "nodejs20"
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  },
  "emulators": {
    "functions": { "port": 5001 },
    "firestore":  { "port": 8080 },
    "auth":       { "port": 9099 },
    "storage":    { "port": 9199 },
    "ui":         { "enabled": true, "port": 4000 },
    "hosting":    { "port": 5000 },
    "singleProjectMode": true
  },
  "hosting": {
    "source": ".",
    "frameworksBackend": {}
  }
}
EOF
  echo "  created  firebase.json"
  created=1
else
  echo "  exists   firebase.json"
fi

# ── firestore.rules ────────────────────────────────────────────────────────────
if [ ! -f "firestore.rules" ]; then
  cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() { return request.auth != null; }
    function isStaff() { return signedIn() && request.auth.token.role in ['admin', 'owner']; }
    function isOwnerOnCreate() {
      return signedIn() && request.resource.data.userId == request.auth.uid;
    }
    function isOwnerOnExisting() {
      return signedIn() && resource.data.userId == request.auth.uid;
    }

    // Emulator-only: allow full access during local development.
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
EOF
  echo "  created  firestore.rules"
  created=1
else
  echo "  exists   firestore.rules"
fi

# ── .env.development ───────────────────────────────────────────────────────────
if [ ! -f ".env.development" ]; then
  cat > .env.development << 'EOF'
NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyBIXRC1pD1Ninr1S_PgGPUfwe8uo85XruY
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=black-river-market.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=black-river-market
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=black-river-market.firebasestorage.app
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=926293242580
NEXT_PUBLIC_FIREBASE_APPID=1:926293242580:web:15daa4f180841dbc3c0141

NEXT_PUBLIC_FIREBASE_EMULATOR=true

FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099
FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9199

NEXT_PUBLIC_CODESPACE_NAME=

# Add your Stripe keys after completing Setup steps 4 and 5:
# STRIPE_SECRET_KEY=sk_test_...
# STRIPE_WEBHOOK_SECRET=whsec_...
EOF
  echo "  created  .env.development  (add your Stripe keys before running npm run dev)"
  created=1
else
  echo "  exists   .env.development"
fi

# ── .firebase-data dir ─────────────────────────────────────────────────────────
if [ ! -d ".firebase-data" ]; then
  mkdir -p .firebase-data
  echo "  created  .firebase-data/"
  created=1
else
  echo "  exists   .firebase-data/"
fi

echo ""
if [ "$created" -eq 1 ]; then
  echo "Done. Before running 'npm run dev', open .env.development and add:"
  echo "  STRIPE_SECRET_KEY=sk_test_..."
  echo "  STRIPE_WEBHOOK_SECRET=whsec_..."
else
  echo "All local config files already exist. Nothing to do."
fi

"use client";

import Button from "@mui/material/Button";
import Link from "@mui/material/Link";
import { RouterLink } from "src/routes/components";

export default function Page() {
  return (
    <main style={{ padding: 24 }}>
      <h1>Assignment 3: My New Page</h1>

      <p>
        <strong>URL:</strong> /a3-benson
      </p>

      <p>
        <strong>File:</strong> src/app/a3-benson/page.jsx
      </p>

      <Button variant="contained" color="primary" style={{ marginBottom: 16 }}>
        Click Me
      </Button>

      <br />

      <Link component={RouterLink} href="/">
        Back to Home
      </Link>
    </main>
  );
}

export function Footer() {
  return (
    <footer className="border-t border-border px-6 py-12">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-6 md:flex-row md:justify-between">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium">Echo</span>
          <span className="text-sm text-muted-foreground">
            · Voice to text for Mac
          </span>
        </div>

        <nav className="flex flex-wrap items-center justify-center gap-6 text-sm text-muted-foreground">
          <a
            href="/docs"
            className="transition-colors hover:text-foreground"
          >
            Docs
          </a>
          <a
            href="/docs/troubleshooting"
            className="transition-colors hover:text-foreground"
          >
            Support
          </a>
          <a
            href="/docs/privacy"
            className="transition-colors hover:text-foreground"
          >
            Privacy
          </a>
          <a
            href="https://github.com/vincenthopf/Echo"
            target="_blank"
            rel="noopener noreferrer"
            className="transition-colors hover:text-foreground"
          >
            GitHub
          </a>
        </nav>

        <p className="text-sm text-muted-foreground">
          Made by Vincent Hopf
        </p>
      </div>
    </footer>
  );
}

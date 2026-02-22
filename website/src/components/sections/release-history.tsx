"use client";

import { useEffect, useState } from "react";
import { BlurFade } from "@/components/ui/blur-fade";
import {
  fetchReleases,
  getDmgAsset,
  formatBytes,
  formatDate,
  type GitHubRelease,
} from "@/lib/github";

function ReleaseCard({ release, index }: { release: GitHubRelease; index: number }) {
  const dmg = getDmgAsset(release);
  const version = release.tag_name.replace(/^v/, "");

  return (
    <BlurFade delay={0.05 * index} inView>
      <article className="rounded-xl border border-border bg-card p-6 transition-colors hover:bg-accent/50">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div className="min-w-0 flex-1">
            <div className="flex items-baseline gap-3">
              <h3 className="text-xl font-semibold tracking-tight">
                {version}
              </h3>
              <time
                dateTime={release.published_at}
                className="text-sm text-muted-foreground"
              >
                {formatDate(release.published_at)}
              </time>
            </div>

            {release.body && (
              <div
                className="prose prose-sm dark:prose-invert mt-3 max-w-none text-muted-foreground [&_h1]:text-base [&_h2]:text-base [&_h3]:text-sm [&_ul]:mt-1 [&_li]:mt-0"
                dangerouslySetInnerHTML={{ __html: markdownToHtml(release.body) }}
              />
            )}
          </div>

          {dmg && (
            <a
              href={dmg.browser_download_url}
              className="inline-flex shrink-0 items-center gap-2 rounded-lg border border-border bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent"
            >
              <svg
                className="h-4 w-4"
                fill="none"
                stroke="currentColor"
                strokeWidth={2}
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M4 16v2a2 2 0 002 2h12a2 2 0 002-2v-2M7 10l5 5m0 0l5-5m-5 5V3"
                />
              </svg>
              <span>Download</span>
              <span className="text-muted-foreground">{formatBytes(dmg.size)}</span>
            </a>
          )}
        </div>
      </article>
    </BlurFade>
  );
}

/** Minimal markdown to HTML for release notes (headings, lists, bold, links, paragraphs). */
function markdownToHtml(md: string): string {
  return md
    .replace(/^### (.+)$/gm, "<h3>$1</h3>")
    .replace(/^## (.+)$/gm, "<h2>$1</h2>")
    .replace(/^# (.+)$/gm, "<h1>$1</h1>")
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>')
    .replace(/^[*-] (.+)$/gm, "<li>$1</li>")
    .replace(/((?:<li>.*<\/li>\n?)+)/g, "<ul>$1</ul>")
    .replace(/\n{2,}/g, "\n");
}

export function ReleaseHistory() {
  const [releases, setReleases] = useState<GitHubRelease[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    fetchReleases()
      .then((r) => setReleases(r))
      .catch(() => setError(true))
      .finally(() => setLoading(false));
  }, []);

  return (
    <section className="mx-auto max-w-3xl px-6 py-24">
      <BlurFade delay={0} inView>
        <h2 className="text-2xl font-bold tracking-tight sm:text-3xl">
          All Versions
        </h2>
        <p className="mt-2 text-muted-foreground">
          Every release, ready when you need it.
        </p>
      </BlurFade>

      <div className="mt-10 space-y-4">
        {loading && (
          <div className="flex items-center justify-center py-12">
            <div className="h-6 w-6 animate-spin rounded-full border-2 border-primary border-t-transparent" />
          </div>
        )}

        {error && (
          <p className="py-12 text-center text-muted-foreground">
            Couldn&apos;t load releases.{" "}
            <a
              href="https://github.com/vincenthopf/Echo/releases"
              className="text-primary underline underline-offset-4"
              target="_blank"
              rel="noopener"
            >
              View on GitHub
            </a>
          </p>
        )}

        {releases.map((release, i) => (
          <ReleaseCard key={release.id} release={release} index={i} />
        ))}
      </div>
    </section>
  );
}

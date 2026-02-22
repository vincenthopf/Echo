const REPO = "vincenthopf/Echo";

export type GitHubAsset = {
  name: string;
  browser_download_url: string;
  size: number;
};

export type GitHubRelease = {
  id: number;
  tag_name: string;
  name: string;
  body: string;
  published_at: string;
  assets: GitHubAsset[];
  prerelease: boolean;
  draft: boolean;
};

export async function fetchReleases(): Promise<GitHubRelease[]> {
  const res = await fetch(
    `https://api.github.com/repos/${REPO}/releases`,
    { headers: { Accept: "application/vnd.github+json" } }
  );
  if (!res.ok) throw new Error(`GitHub API error: ${res.status}`);
  const releases: GitHubRelease[] = await res.json();
  return releases.filter((r) => !r.draft && !r.prerelease);
}

export function getDmgAsset(release: GitHubRelease): GitHubAsset | undefined {
  return release.assets.find((a) => a.name.endsWith(".dmg"));
}

export function formatBytes(bytes: number): string {
  const mb = bytes / (1024 * 1024);
  return `${mb.toFixed(1)} MB`;
}

export function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

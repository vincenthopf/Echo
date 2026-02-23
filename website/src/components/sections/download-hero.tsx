"use client";

import { useEffect, useRef, useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { type ConfettiRef, Confetti } from "@/components/ui/confetti";
import { DottedGlowBackground } from "@/components/ui/dotted-glow-background";
import { BlurFade } from "@/components/ui/blur-fade";
import {
  fetchReleases,
  getDmgAsset,
  formatBytes,
  type GitHubRelease,
} from "@/lib/github";

export function DownloadHero() {
  const confettiRef = useRef<ConfettiRef>(null);
  const [count, setCount] = useState(3);
  const [phase, setPhase] = useState<"countdown" | "done">("countdown");
  const [latest, setLatest] = useState<GitHubRelease | null>(null);
  const [error, setError] = useState(false);
  const downloadTriggered = useRef(false);

  // Fetch latest release
  useEffect(() => {
    fetchReleases()
      .then((releases) => {
        if (releases.length > 0) setLatest(releases[0]);
        else setError(true);
      })
      .catch(() => setError(true));
  }, []);

  // Countdown timer
  useEffect(() => {
    if (phase !== "countdown") return;
    if (count <= 0) {
      setPhase("done");
      return;
    }
    const timer = setTimeout(() => setCount((c) => c - 1), 1000);
    return () => clearTimeout(timer);
  }, [count, phase]);

  // Trigger download when countdown ends
  useEffect(() => {
    if (phase !== "done" || downloadTriggered.current) return;
    downloadTriggered.current = true;

    confettiRef.current?.fire({
      particleCount: 100,
      spread: 70,
      origin: { y: 0.6 },
      colors: ["#F5A574", "#F09882", "#E87C9B", "#C4866C", "#D4976C"],
    });

    if (latest) {
      const dmg = getDmgAsset(latest);
      if (dmg) {
        window.location.href = dmg.browser_download_url;
      }
    }
  }, [phase, latest]);

  const dmg = latest ? getDmgAsset(latest) : undefined;
  const version = latest?.tag_name?.replace(/^v/, "") ?? "";
  const fileSize = dmg ? formatBytes(dmg.size) : "";
  const directUrl =
    dmg?.browser_download_url ??
    "https://github.com/vincenthopf/Echo/releases/latest/download/Echo.dmg";

  return (
    <section className="relative flex min-h-screen items-center justify-center overflow-hidden px-6">
      <DottedGlowBackground
        className="pointer-events-none"
        gap={16}
        radius={1.5}
        color="rgba(196, 134, 108, 0.5)"
        darkColor="rgba(212, 151, 108, 0.5)"
        glowColor="rgba(245, 165, 116, 0.85)"
        darkGlowColor="rgba(232, 124, 155, 0.85)"
        opacity={0.5}
        speedScale={0.8}
      />

      <div className="relative z-10 mx-auto max-w-2xl text-center">
        {/* App icon */}
        <BlurFade delay={0}>
          <img
            src="/app-icon.webp"
            alt="Echo"
            className="mx-auto h-24 w-24 rounded-2xl shadow-lg"
          />
        </BlurFade>

        {/* Headline */}
        <BlurFade delay={0.1}>
          <h1 className="mt-8 text-3xl font-bold tracking-tight sm:text-4xl md:text-5xl">
            {phase === "done"
              ? "Echo is on its way."
              : "Thanks for choosing Echo."}
          </h1>
        </BlurFade>

        <BlurFade delay={0.2}>
          <p className="mt-4 text-lg text-muted-foreground">
            {phase === "done"
              ? "Open the file and drag Echo to your Applications folder."
              : "Your download starts in just a moment."}
          </p>
        </BlurFade>

        {/* Countdown / completion */}
        <div className="mt-12 flex h-40 items-center justify-center">
          <AnimatePresence mode="wait">
            {phase === "countdown" && count > 0 ? (
              <motion.div
                key={count}
                initial={{ opacity: 0, y: 20, rotateX: -80 }}
                animate={{ opacity: 1, y: 0, rotateX: 0 }}
                exit={{ opacity: 0, y: -20, rotateX: 80 }}
                transition={{ duration: 0.4, ease: [0.23, 1, 0.32, 1] }}
                className="flex h-32 w-24 items-center justify-center rounded-2xl border border-border bg-card shadow-lg sm:h-36 sm:w-28"
                style={{ perspective: 800 }}
              >
                <span className="text-7xl font-bold tabular-nums text-primary sm:text-8xl">
                  {count}
                </span>
              </motion.div>
            ) : phase === "done" ? (
              <motion.div
                key="done"
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.5, type: "spring" }}
                className="flex h-32 w-24 items-center justify-center rounded-2xl border border-border bg-card shadow-lg sm:h-36 sm:w-28"
              >
                <svg
                  className="h-16 w-16 text-primary"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2.5}
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
              </motion.div>
            ) : null}
          </AnimatePresence>
        </div>

        {/* Version info + fallback */}
        <BlurFade delay={0.3}>
          <div className="mt-8 space-y-3">
            {version && (
              <p className="text-sm text-muted-foreground">
                Version {version}
                {fileSize && ` · ${fileSize}`} · macOS 15+
              </p>
            )}
            <a
              href={directUrl}
              className="text-sm text-primary underline underline-offset-4 hover:text-primary/80"
            >
              Download didn&apos;t start? Download manually.
            </a>
          </div>
        </BlurFade>

        {/* Scroll hint */}
        {phase === "done" && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 2 }}
            className="mt-16"
          >
            <p className="text-sm text-muted-foreground">
              Looking for an earlier version?
            </p>
            <svg
              className="mx-auto mt-2 h-5 w-5 animate-bounce text-muted-foreground"
              fill="none"
              stroke="currentColor"
              strokeWidth={2}
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M19 9l-7 7-7-7"
              />
            </svg>
          </motion.div>
        )}
      </div>

      <Confetti
        ref={confettiRef}
        className="pointer-events-none absolute inset-0 z-50 h-full w-full"
        manualstart
      />
    </section>
  );
}

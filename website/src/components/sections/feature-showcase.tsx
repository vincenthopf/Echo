"use client";

import { BlurFade } from "@/components/ui/blur-fade";
import { InteractiveHoverButton } from "@/components/ui/interactive-hover-button";
import { useTheme } from "next-themes";
import { useEffect, useState } from "react";

export function FeatureShowcase() {
  const { resolvedTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  const isDark = mounted && resolvedTheme === "dark";

  return (
    <section className="relative px-6 py-20 md:py-28">
      <div className="mx-auto max-w-6xl">
        {/* Section heading — left-aligned */}
        <BlurFade delay={0.1} inView>
          <div className="mb-20 max-w-lg md:mb-28">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
              Built for the way
              <br />
              you work.
            </h2>
            <p className="mt-4 text-muted-foreground">
              Every feature exists because someone needed it. Probably you.
            </p>
          </div>
        </BlurFade>

        {/* Feature 1: Local AI — large screenshot with text below in columns */}
        <div className="mb-24 md:mb-36">
          <BlurFade delay={0.15} inView>
            <div className="relative overflow-hidden rounded-2xl border border-border bg-card p-2 shadow-lg shadow-black/5 dark:shadow-black/20">
              <div className="overflow-hidden rounded-xl">
                <img
                  src={
                    isDark
                      ? "/screenshots/Darkmode-dashboard.png"
                      : "/screenshots/Lightmode-dashboard.png"
                  }
                  alt="Echo dashboard with transcription metrics"
                  className="w-full scale-[1.1]"
                />
              </div>
            </div>
          </BlurFade>
          <BlurFade delay={0.25} inView>
            <div className="mt-8 grid gap-6 md:grid-cols-3 md:gap-12">
              <div>
                <span className="text-sm font-semibold uppercase tracking-widest text-primary">
                  Local AI
                </span>
                <h3 className="mt-2 text-2xl font-bold tracking-tight">
                  Private by design. Powerful by default.
                </h3>
              </div>
              <div className="md:col-span-2">
                <p className="text-muted-foreground leading-relaxed">
                  On-device models in multiple sizes — from lightweight to
                  studio-grade. No internet required. No data leaves your Mac.
                  And if you want cloud transcription, it&apos;s one toggle
                  away. Your voice, your hardware, your call.
                </p>
                <div className="mt-4 flex flex-wrap items-center gap-3">
                  {[
                    "Complete privacy",
                    "Works offline",
                    "Multiple engines",
                    "Cloud when you want it",
                  ].map((tag) => (
                    <span
                      key={tag}
                      className="rounded-full border border-border px-3 py-1 text-xs text-muted-foreground"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </BlurFade>
        </div>

        {/* Feature 2: Floating Overlay — centered image, text below */}
        <div className="mb-24 md:mb-36">
          <BlurFade delay={0.15} inView>
            <div className="mx-auto max-w-2xl">
              <div className="overflow-hidden rounded-3xl">
                <img
                  src={
                    isDark
                      ? "/screenshots/TranscribingDarkmode.png"
                      : "/screenshots/TranscribingLightmode.png"
                  }
                  alt="Echo floating overlay showing live audio waveform"
                  className="w-full"
                />
              </div>
            </div>
          </BlurFade>
          <BlurFade delay={0.25} inView>
            <div className="mt-8 mx-auto max-w-2xl text-center">
              <span className="text-sm font-semibold uppercase tracking-widest text-primary">
                Minimal Overlay
              </span>
              <h3 className="mt-2 text-2xl font-bold tracking-tight">
                Stays out of your way.
              </h3>
              <p className="mt-4 text-muted-foreground leading-relaxed">
                A floating recorder that overlays whatever you&apos;re doing.
                Press your hotkey, speak, and watch the waveform respond.
                When you&apos;re done, it disappears.
              </p>
            </div>
          </BlurFade>
        </div>

        {/* Feature 3: Adaptive Awareness — text left, screenshot right */}
        <div className="mb-24 md:mb-36">
          <div className="grid items-center gap-8 md:grid-cols-[2fr_3fr] md:gap-16">
            <BlurFade delay={0.15} inView direction="left" className="order-2 md:order-1">
              <div>
                <span className="text-sm font-semibold uppercase tracking-widest text-primary">
                  Adaptive Awareness
                </span>
                <h3 className="mt-2 text-2xl font-bold tracking-tight sm:text-3xl">
                  Echo reads the room.
                </h3>
                <p className="mt-4 text-muted-foreground leading-relaxed">
                  Profiles that switch the moment your context changes.
                  Prompting AI in ChatGPT? Technical vocabulary, no formatting.
                  Drafting in Mail? Full sentences, proper punctuation. Chatting
                  in Messages? Casual, fast, no fuss. You set it once. Echo
                  handles the rest.
                </p>
                <ul className="mt-6 space-y-3">
                  {[
                    "App-aware \u2014 settings change with your active app",
                    "URL-aware \u2014 profiles match the site you\u2019re on",
                    "Voice triggers \u2014 say a word, switch instantly",
                  ].map((item) => (
                    <li
                      key={item}
                      className="flex items-start gap-3 text-sm text-muted-foreground"
                    >
                      <svg
                        className="mt-0.5 h-4 w-4 flex-shrink-0 text-primary"
                        xmlns="http://www.w3.org/2000/svg"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2.5"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
            </BlurFade>
            <BlurFade delay={0.3} inView direction="right" className="order-1 md:order-2">
              <div className="overflow-hidden rounded-2xl border border-border bg-card p-2 shadow-lg shadow-black/5 dark:shadow-black/20">
                <div className="overflow-hidden rounded-xl">
                  <img
                    src={
                      isDark
                        ? "/screenshots/Darkmode-Adaptive-awareness.png"
                        : "/screenshots/lightmode-Adaptive-awareness.png"
                    }
                    alt="Adaptive Awareness profile settings with app triggers"
                    className="w-full scale-[1.1]"
                  />
                </div>
              </div>
            </BlurFade>
          </div>
        </div>

        {/* Feature 3: Smart Vocabulary — screenshot left, text right */}
        <div className="mb-24 md:mb-36">
          <div className="grid items-center gap-8 md:grid-cols-[3fr_2fr] md:gap-16">
            <BlurFade delay={0.15} inView direction="left">
              <div className="overflow-hidden rounded-2xl border border-border bg-card p-2 shadow-lg shadow-black/5 dark:shadow-black/20">
                <div className="overflow-hidden rounded-xl">
                  <img
                    src={
                      isDark
                        ? "/screenshots/Darkmode-vocab.png"
                        : "/screenshots/lightmode-vocab.png"
                    }
                    alt="Smart vocabulary and word replacement settings"
                    className="w-full scale-[1.1]"
                  />
                </div>
              </div>
            </BlurFade>
            <BlurFade delay={0.3} inView direction="right">
              <div>
                <span className="text-sm font-semibold uppercase tracking-widest text-primary">
                  Smart Vocabulary
                </span>
                <h3 className="mt-2 text-2xl font-bold tracking-tight sm:text-3xl">
                  It speaks your language. Literally.
                </h3>
                <p className="mt-4 text-muted-foreground leading-relaxed">
                  Add the words that matter to you — brand names, technical
                  terms, abbreviations, the shorthand only your team uses.
                  Echo learns them and gets them right, every time.
                </p>
                <ul className="mt-6 space-y-3">
                  {[
                    "Custom vocabulary \u2014 names, terms, and jargon, always accurate",
                    "Auto-replace \u2014 say one thing, output another",
                    "Smart corrections \u2014 accuracy that improves the more you use it",
                  ].map((item) => (
                    <li
                      key={item}
                      className="flex items-start gap-3 text-sm text-muted-foreground"
                    >
                      <svg
                        className="mt-0.5 h-4 w-4 flex-shrink-0 text-primary"
                        xmlns="http://www.w3.org/2000/svg"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2.5"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
            </BlurFade>
          </div>
        </div>

        {/* Feature 4: Advanced Control — centered screenshot, text below right-aligned */}
        <div>
          <BlurFade delay={0.15} inView>
            <div className="mx-auto max-w-4xl">
              <div className="overflow-hidden rounded-2xl border border-border bg-card p-2 shadow-lg shadow-black/5 dark:shadow-black/20">
                <div className="overflow-hidden rounded-xl">
                  <img
                    src={
                      isDark
                        ? "/screenshots/Advanced Settings.png"
                        : "/screenshots/Advanced Settings lightmode.png"
                    }
                    alt="Advanced settings with Type-Out Mode and Auto-Send controls"
                    className="w-full scale-[1.1]"
                  />
                </div>
              </div>
            </div>
          </BlurFade>
          <BlurFade delay={0.25} inView>
            <div className="mt-8 grid gap-6 md:grid-cols-3 md:gap-12">
              <div className="md:col-start-2 md:col-span-2">
                <span className="text-sm font-semibold uppercase tracking-widest text-primary">
                  Advanced Control
                </span>
                <h3 className="mt-2 text-2xl font-bold tracking-tight">
                  Your workflow. Down to the keystroke.
                </h3>
              </div>
              <div className="md:col-start-2">
                <p className="text-muted-foreground leading-relaxed text-sm">
                  Type-Out Mode simulates real typing — character by character,
                  in any app, even ones that block paste. Auto-Send transcribes
                  and hits enter for you.
                </p>
              </div>
              <div>
                <p className="text-muted-foreground leading-relaxed text-sm">
                  Pause your music when you start talking. Copy to clipboard or
                  paste at cursor. Adjust every detail until it fits the way you
                  work — then forget it&apos;s there.
                </p>
                <div className="mt-6">
                  <InteractiveHoverButton
                    className="text-sm px-5 py-2"
                    onClick={() => window.open("https://github.com/vincenthopf/Echo/releases/latest/download/Echo.dmg", "_blank")}
                  >
                    Download for Mac
                  </InteractiveHoverButton>
                </div>
              </div>
            </div>
          </BlurFade>
        </div>
      </div>
    </section>
  );
}

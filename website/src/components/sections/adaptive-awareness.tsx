"use client";

import { useState } from "react";
import { BlurFade } from "@/components/ui/blur-fade";
import { motion, AnimatePresence } from "motion/react";

/* ────────────────────────────────────────────────────────────────────────── */
/*  Mode data                                                                */
/* ────────────────────────────────────────────────────────────────────────── */

interface Mode {
  id: string;
  label: string;
  icon: React.ReactNode;
  voiceInput: string;
  enhancedOutput: string;
}

const modes: Mode[] = [
  {
    id: "default",
    label: "Default",
    icon: (
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z" />
        <path d="M19 10v2a7 7 0 0 1-14 0v-2" />
        <line x1="12" x2="12" y1="19" y2="22" />
      </svg>
    ),
    voiceInput:
      "so basically i wanted to say that the new features we shipped last week are working really well and um the crash rate dropped by like forty percent which is pretty awesome",
    enhancedOutput:
      "The new features we shipped last week are performing well. The crash rate has dropped by 40%, which is a significant improvement.",
  },
  {
    id: "email",
    label: "Email",
    icon: (
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <rect width="20" height="16" x="2" y="4" rx="2" />
        <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7" />
      </svg>
    ),
    voiceInput:
      "hi sarah i'd like to talk about the new landing page design and uh maybe we can meet next tuesday afternoon to discuss the changes and stuff",
    enhancedOutput: `Subject: Landing Page Design Discussion

Hi Sarah,

I'd like to discuss the new landing page design with you. Would you be available next Tuesday afternoon to go over the proposed changes?

Looking forward to your thoughts.

Best regards`,
  },
  {
    id: "tweet",
    label: "Tweet",
    icon: (
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6 2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4-.9-4.2 4-6.6 7-3.8 1.1 0 3-1.2 3-1.2z" />
      </svg>
    ),
    voiceInput:
      "hey everyone just wanted to let you know that we've been working on some really cool new AI features that will make your workflow so much better and more productive",
    enhancedOutput:
      "We've been cooking up some exciting AI features that will supercharge your workflow. Can't wait to share what's coming next! \u{1F680}\u{2728}",
  },
  {
    id: "chat",
    label: "Chat",
    icon: (
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M7.9 20A9 9 0 1 0 4 16.1L2 22z" />
      </svg>
    ),
    voiceInput:
      "hey team just wanted to give you a quick update on the project we finished the design review and the backend API is done and we're starting frontend work tomorrow",
    enhancedOutput: `Hey team! Quick project update:

\u{2705} Design review \u2014 complete
\u{2705} Backend API \u2014 done
\u{1F3D7}\u{FE0F} Frontend work \u2014 starting tomorrow

Let me know if you have any questions!`,
  },
];

/* ────────────────────────────────────────────────────────────────────────── */
/*  Subcomponents                                                            */
/* ────────────────────────────────────────────────────────────────────────── */

function ProcessingDivider() {
  return (
    <div className="flex items-center gap-3 py-4">
      <div className="h-px flex-1 bg-border" />
      <div className="flex items-center gap-2 text-xs font-medium text-primary">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z" />
        </svg>
        <span>AI Enhancement</span>
      </div>
      <div className="h-px flex-1 bg-border" />
    </div>
  );
}

function FeatureCard({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
}) {
  return (
    <div className="rounded-xl border border-border bg-card p-5 sm:p-6">
      <div className="mb-3 flex h-9 w-9 items-center justify-center rounded-lg bg-primary/10 text-primary">
        {icon}
      </div>
      <h4 className="text-sm font-semibold">{title}</h4>
      <p className="mt-1 text-sm leading-relaxed text-muted-foreground">
        {description}
      </p>
    </div>
  );
}

/* ────────────────────────────────────────────────────────────────────────── */
/*  Main section                                                             */
/* ────────────────────────────────────────────────────────────────────────── */

export function AdaptiveAwareness() {
  const [activeMode, setActiveMode] = useState("default");
  const current = modes.find((m) => m.id === activeMode)!;

  return (
    <section id="adaptive-awareness" className="relative px-6 py-20 md:py-28">
      {/* Subtle gradient backdrop */}
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 overflow-hidden"
      >
        <div className="absolute left-1/2 top-0 h-[600px] w-[900px] -translate-x-1/2 -translate-y-1/3 rounded-full bg-gradient-to-br from-[var(--gradient-start)] via-[var(--gradient-mid)] to-[var(--gradient-end)] opacity-[0.04] blur-3xl dark:opacity-[0.06]" />
      </div>

      <div className="relative mx-auto max-w-4xl">
        {/* ── Header — centered ── */}
        <BlurFade delay={0.1} inView>
          <div className="mb-12 text-center md:mb-16">
            <span className="text-sm font-semibold uppercase tracking-widest text-primary">
              Adaptive Awareness
            </span>
            <h2 className="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">
              One voice. Every format.
            </h2>
            <p className="mx-auto mt-4 max-w-xl text-muted-foreground">
              Speak naturally and let Echo shape the output for the moment.
              Emails get structure. Tweets get brevity. Chat gets personality.
              You just talk.
            </p>
          </div>
        </BlurFade>

        {/* ── Interactive demo card ── */}
        <BlurFade delay={0.2} inView>
          <div className="overflow-hidden rounded-2xl border border-border bg-card shadow-lg shadow-black/5 dark:shadow-black/20">
            {/* Tab bar */}
            <div className="border-b border-border bg-secondary/30 px-4 py-3 sm:px-6">
              <div className="flex flex-wrap gap-2">
                {modes.map((mode) => (
                  <button
                    key={mode.id}
                    onClick={() => setActiveMode(mode.id)}
                    className={`inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-sm font-medium transition-all ${
                      activeMode === mode.id
                        ? "bg-primary text-primary-foreground shadow-sm"
                        : "text-muted-foreground hover:bg-secondary hover:text-foreground"
                    }`}
                  >
                    {mode.icon}
                    {mode.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Content area */}
            <div className="p-5 sm:p-8">
              {/* Active mode badge */}
              <div className="mb-6 flex items-center gap-2">
                <span className="text-base font-semibold">{current.label}</span>
                <span className="inline-flex items-center gap-1 rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary">
                  <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                  Active
                </span>
              </div>

              <AnimatePresence mode="wait">
                <motion.div
                  key={current.id}
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -8 }}
                  transition={{ duration: 0.25, ease: "easeOut" }}
                >
                  {/* Voice input */}
                  <div>
                    <div className="mb-2 flex items-center gap-2 text-xs font-medium uppercase tracking-wider text-muted-foreground">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="12"
                        height="12"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z" />
                        <path d="M19 10v2a7 7 0 0 1-14 0v-2" />
                        <line x1="12" x2="12" y1="19" y2="22" />
                      </svg>
                      Voice Input
                    </div>
                    <div className="rounded-xl bg-secondary/50 p-4">
                      <p className="text-sm italic leading-relaxed text-muted-foreground">
                        &ldquo;{current.voiceInput}&rdquo;
                      </p>
                    </div>
                  </div>

                  {/* Divider */}
                  <ProcessingDivider />

                  {/* Enhanced output */}
                  <div>
                    <div className="mb-2 flex items-center gap-2 text-xs font-medium uppercase tracking-wider text-muted-foreground">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="12"
                        height="12"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z" />
                      </svg>
                      Enhanced Output
                    </div>
                    <div className="rounded-xl border border-border bg-background p-4">
                      <p className="whitespace-pre-line text-sm leading-relaxed">
                        {current.enhancedOutput}
                      </p>
                    </div>
                  </div>
                </motion.div>
              </AnimatePresence>
            </div>
          </div>
        </BlurFade>

        {/* ── Feature cards ── */}
        <BlurFade delay={0.35} inView>
          <div className="mt-8 grid gap-4 sm:grid-cols-3">
            <FeatureCard
              icon={
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <circle cx="12" cy="12" r="3" />
                  <path d="M12 1v4" />
                  <path d="M12 19v4" />
                  <path d="m4.6 4.6 2.8 2.8" />
                  <path d="m16.6 16.6 2.8 2.8" />
                  <path d="M1 12h4" />
                  <path d="M19 12h4" />
                  <path d="m4.6 19.4 2.8-2.8" />
                  <path d="m16.6 7.4 2.8-2.8" />
                </svg>
              }
              title="Context-Aware"
              description="Detects the active app, URL, or voice trigger and automatically applies the right profile."
            />
            <FeatureCard
              icon={
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z" />
                </svg>
              }
              title="Seamless Switching"
              description="Transition between writing styles instantly. No menus, no settings to toggle. Just speak."
            />
            <FeatureCard
              icon={
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="18"
                  height="18"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M12 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
                  <path d="M18.375 2.625a1 1 0 0 1 3 3l-9.013 9.014a2 2 0 0 1-.853.505l-2.873.84a.5.5 0 0 1-.62-.62l.84-2.873a2 2 0 0 1 .506-.852z" />
                </svg>
              }
              title="Custom Modes"
              description="Create your own profiles with custom AI prompts, triggers, and formatting rules."
            />
          </div>
        </BlurFade>
      </div>
    </section>
  );
}

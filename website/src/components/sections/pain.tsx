"use client";

import { BlurFade } from "@/components/ui/blur-fade";
import { MagicCard } from "@/components/ui/magic-card";
import { useTheme } from "next-themes";
import {
  AudioLines,
  DollarSign,
  ShieldOff,
  Shuffle,
} from "lucide-react";
import { useEffect, useState } from "react";

const painPoints = [
  {
    icon: AudioLines,
    title: "Built-in dictation is built for basics.",
    description:
      "Misheard words. No formatting. No technical terms. Fine for a grocery list — not for your actual work.",
  },
  {
    icon: DollarSign,
    title: "Good tools cost $15 a month.",
    description:
      "Wispr Flow, Superwhisper — monthly subscriptions for something that should be a utility. You pay forever for a problem that\u2019s already solved.",
  },
  {
    icon: ShieldOff,
    title: "Your voice goes to someone else\u2019s server.",
    description:
      "Client notes. Medical records. Source code. All sent to infrastructure you don\u2019t control, governed by policies you didn\u2019t write.",
  },
  {
    icon: Shuffle,
    title: "Yesterday\u2019s accuracy is today\u2019s hallucination.",
    description:
      "Cloud providers swap models without asking. The transcription that worked last week breaks this week. No warning. No recourse.",
  },
];

export function Pain() {
  const { resolvedTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  const isDark = mounted && resolvedTheme === "dark";

  return (
    <section className="relative px-6 pt-14 pb-20 md:py-28">
      <div className="mx-auto max-w-5xl">
        <BlurFade delay={0.1} inView>
          <div className="max-w-lg">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
              Voice typing should have worked by now.
            </h2>
            <p className="mt-4 text-muted-foreground">
              It hasn&apos;t. Here&apos;s why.
            </p>
          </div>
        </BlurFade>

        <div className="mt-14 grid gap-5 md:mt-20 md:grid-cols-2">
          {painPoints.map((point, index) => {
            const Icon = point.icon;
            return (
              <BlurFade key={point.title} delay={0.2 + index * 0.1} inView>
                <MagicCard
                  className="h-full rounded-xl border border-border/60"
                  gradientColor={isDark ? "rgba(212, 151, 108, 0.07)" : "rgba(196, 134, 108, 0.07)"}
                  gradientFrom="var(--gradient-start)"
                  gradientTo="var(--gradient-end)"
                  gradientOpacity={0.15}
                  gradientSize={250}
                >
                  <div className="flex flex-col gap-3 p-6">
                    <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-gradient-to-br from-[var(--gradient-start)]/10 to-[var(--gradient-end)]/10">
                      <Icon className="h-4.5 w-4.5 text-primary" />
                    </div>
                    <h3 className="text-base font-semibold tracking-tight">
                      {point.title}
                    </h3>
                    <p className="text-sm leading-relaxed text-muted-foreground">
                      {point.description}
                    </p>
                  </div>
                </MagicCard>
              </BlurFade>
            );
          })}
        </div>
      </div>
    </section>
  );
}

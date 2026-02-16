"use client";

import { useRef } from "react";
import {
  motion,
  useScroll,
  useTransform,
  useInView,
  type MotionValue,
} from "motion/react";
import { BlurFade } from "@/components/ui/blur-fade";
import { TypingAnimation } from "@/components/ui/typing-animation";

/* ─── Step 1: Keyboard Key Press ─── */

function HotkeyVisual() {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.5 });

  return (
    <div
      ref={ref}
      className="flex items-center justify-center gap-2 px-6 py-10"
    >
      {[
        { label: "⌥", width: "w-12" },
        { label: "Space", width: "w-20" },
      ].map((key, i) => (
        <motion.div
          key={key.label}
          className={`${key.width} relative flex h-10 items-center justify-center rounded-lg border border-border bg-background font-mono text-xs font-medium text-foreground shadow-[0_3px_0_0_var(--border)] select-none`}
          animate={
            isInView
              ? {
                  y: [0, 3, 0],
                  boxShadow: [
                    "0 3px 0 0 var(--border)",
                    "0 0px 0 0 var(--border)",
                    "0 3px 0 0 var(--border)",
                  ],
                }
              : {}
          }
          transition={{
            duration: 0.25,
            delay: 0.5 + i * 0.06,
            ease: "easeInOut",
            repeat: Infinity,
            repeatDelay: 3,
          }}
        >
          {key.label}
        </motion.div>
      ))}
    </div>
  );
}

/* ─── Step 2: Audio Waveform ─── */

function WaveformVisual() {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.5 });

  const bars = [0.25, 0.45, 0.7, 0.5, 1, 0.65, 0.85, 0.4, 0.6, 0.8, 0.45, 0.25];

  return (
    <div
      ref={ref}
      className="flex items-center justify-center gap-[3px] px-6 py-10"
    >
      {bars.map((intensity, i) => (
        <motion.div
          key={i}
          className="w-[3px] rounded-full bg-gradient-to-t from-[var(--gradient-start)] to-[var(--gradient-end)]"
          style={{ height: 36, originY: 0.5 }}
          initial={{ scaleY: 0.08, opacity: 0 }}
          animate={
            isInView
              ? {
                  scaleY: [0.12, intensity, 0.12],
                  opacity: 1,
                }
              : {}
          }
          transition={{
            scaleY: {
              duration: 0.9 + i * 0.05,
              repeat: Infinity,
              ease: "easeInOut",
              delay: i * 0.07,
            },
            opacity: { duration: 0.3, delay: i * 0.03 },
          }}
        />
      ))}
    </div>
  );
}

/* ─── Step 3: Text Appearing ─── */

function TextOutputVisual() {
  return (
    <div className="px-6 py-10">
      <TypingAnimation
        words={[
          "Meeting moved to 3pm — I'll send the agenda beforehand.",
          "Just reviewed the PR, looks good to merge.",
          "Can you share the design file? I'll take a look this afternoon.",
        ]}
        typeSpeed={35}
        deleteSpeed={15}
        pauseDelay={2500}
        loop
        showCursor
        blinkCursor
        cursorStyle="line"
        className="text-sm leading-relaxed text-foreground/70"
        startOnView
      />
    </div>
  );
}

/* ─── Timeline Dot ─── */

function StepDot({
  index,
  scrollProgress,
}: {
  index: number;
  scrollProgress: MotionValue<number>;
}) {
  const start = index * 0.33;
  const end = start + 0.12;

  const fillOpacity = useTransform(scrollProgress, [start, end], [0, 1]);
  const dotScale = useTransform(scrollProgress, [start, end], [1, 1.3]);
  const ringScale = useTransform(scrollProgress, [start, end, end + 0.15], [0.8, 1.6, 2.5]);
  const ringOpacity = useTransform(scrollProgress, [start, start + 0.02, end + 0.05], [0, 0.5, 0]);
  const glowOpacity = useTransform(scrollProgress, [start, end, end + 0.15], [0, 0.6, 0]);

  return (
    <div className="relative flex h-3 w-3 items-center justify-center">
      {/* Expanding ring pulse */}
      <motion.div
        className="absolute h-8 w-8 rounded-full"
        style={{
          scale: ringScale,
          opacity: ringOpacity,
          border: "1px solid var(--gradient-start)",
        }}
      />

      {/* Glow */}
      <motion.div
        className="absolute h-5 w-5 rounded-full"
        style={{
          opacity: glowOpacity,
          background: "radial-gradient(circle, var(--gradient-start), transparent 70%)",
          filter: "blur(3px)",
        }}
      />

      {/* Base dot */}
      <motion.div
        className="relative h-3 w-3 rounded-full border border-border bg-background"
        style={{ scale: dotScale }}
      />

      {/* Gradient fill */}
      <motion.div
        className="absolute h-3 w-3 rounded-full bg-gradient-to-br from-[var(--gradient-start)] to-[var(--gradient-end)]"
        style={{ opacity: fillOpacity, scale: dotScale }}
      />
    </div>
  );
}

/* ─── Steps Config ─── */

const steps = [
  {
    title: "Press one key.",
    description:
      "A global shortcut that works in any app, any window, any context. You set the key. Echo does the rest.",
    visual: <HotkeyVisual />,
  },
  {
    title: "Just talk.",
    description:
      "Speak naturally. Echo transcribes in real time using your preferred engine — on-device AI or cloud. Your choice.",
    visual: <WaveformVisual />,
  },
  {
    title: "Text. Instantly.",
    description:
      "Appears at your cursor, lands in your clipboard, or gets polished by AI before it arrives. However you want it.",
    visual: <TextOutputVisual />,
  },
];

/* ─── Section ─── */

export function HowItWorks() {
  const sectionRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start 0.7", "end 0.5"],
  });

  const lineScaleY = useTransform(scrollYProgress, [0, 1], [0, 1]);

  return (
    <section ref={sectionRef} className="relative px-6 py-20 md:py-28">
      <div className="mx-auto max-w-5xl">
        {/* Section heading */}
        <BlurFade delay={0.1} inView>
          <div className="mb-16 max-w-lg md:mb-20">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
              Thought to text in three steps.
            </h2>
            <p className="mt-4 text-muted-foreground">
              No menus. No setup. No friction.
            </p>
          </div>
        </BlurFade>

        {/* Steps with timeline */}
        <div className="relative">
          {/* Timeline track (background) */}
          <div className="absolute left-[5.5px] top-0 bottom-0 w-px bg-border" />

          {/* Timeline track (filled on scroll) */}
          <motion.div
            className="absolute left-[5.5px] top-0 bottom-0 w-px origin-top bg-gradient-to-b from-[var(--gradient-start)] via-[var(--gradient-mid)] to-[var(--gradient-end)]"
            style={{ scaleY: lineScaleY }}
          />

          {/* Traveling glow at leading edge */}
          <motion.div
            className="absolute left-0 w-3 h-6 -translate-y-1/2 pointer-events-none"
            style={{
              top: useTransform(scrollYProgress, [0, 1], ["0%", "100%"]),
              opacity: useTransform(scrollYProgress, [0, 0.03, 0.92, 1], [0, 0.7, 0.7, 0]),
              background: "radial-gradient(ellipse at center, var(--gradient-start), transparent 70%)",
              filter: "blur(4px)",
            }}
          />

          {/* Steps */}
          <div className="flex flex-col gap-14 md:gap-20">
            {steps.map((step, index) => (
              <BlurFade key={step.title} delay={0.15 + index * 0.1} inView>
                <div className="flex gap-6 md:gap-8">
                  {/* Dot */}
                  <div className="flex-shrink-0 pt-1.5">
                    <StepDot
                      index={index}
                      scrollProgress={scrollYProgress}
                    />
                  </div>

                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <div className="grid gap-4 md:grid-cols-[1fr_1.4fr] md:items-center md:gap-8">
                      {/* Text */}
                      <div>
                        <span className="text-xs font-semibold uppercase tracking-widest text-primary">
                          Step {String(index + 1).padStart(2, "0")}
                        </span>
                        <h3 className="mt-1 text-xl font-semibold md:text-2xl">
                          {step.title}
                        </h3>
                        <p className="mt-2 text-sm leading-relaxed text-muted-foreground max-w-sm">
                          {step.description}
                        </p>
                      </div>

                      {/* Visual demo */}
                      <div className="overflow-hidden rounded-2xl border border-border bg-card/50">
                        {step.visual}
                      </div>
                    </div>
                  </div>
                </div>
              </BlurFade>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

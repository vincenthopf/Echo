"use client";

import { useRef, useState, useCallback } from "react";
import { motion, useInView } from "motion/react";
import { BlurFade } from "@/components/ui/blur-fade";
import { MagicCard } from "@/components/ui/magic-card";
import {
  DollarSign,
  WifiOff,
  ShieldCheck,
  Cloud,
  KeyRound,
  PenLine,
  Monitor,
  Keyboard,
  Mic,
  SlidersHorizontal,
  Code2,
  type LucideIcon,
} from "lucide-react";

/* ─── Data ─── */

type FeatureValue = boolean | string;

interface Feature {
  name: string;
  icon: LucideIcon;
  echo: FeatureValue;
  echoDetail?: string;
  wispr: FeatureValue;
  superwhisper: FeatureValue;
  isPrice?: boolean;
}

const features: Feature[] = [
  {
    name: "Price",
    icon: DollarSign,
    echo: "Free",
    echoDetail: "forever",
    wispr: "$15/mo",
    superwhisper: "$8.49/mo",
    isPrice: true,
  },
  {
    name: "Offline transcription",
    icon: WifiOff,
    echo: true,
    wispr: false,
    superwhisper: true,
  },
  {
    name: "Audio stays on device",
    icon: ShieldCheck,
    echo: true,
    wispr: false,
    superwhisper: true,
  },
  {
    name: "Cloud providers",
    icon: Cloud,
    echo: "5+",
    wispr: "1",
    superwhisper: "6+",
  },
  {
    name: "Bring your own API keys",
    icon: KeyRound,
    echo: true,
    wispr: false,
    superwhisper: true,
  },
  {
    name: "Custom AI prompts",
    icon: PenLine,
    echo: true,
    wispr: false,
    superwhisper: true,
  },
  {
    name: "Screen capture for AI",
    icon: Monitor,
    echo: true,
    wispr: true,
    superwhisper: false,
  },
  {
    name: "Type-out mode",
    icon: Keyboard,
    echo: true,
    wispr: false,
    superwhisper: true,
  },
  {
    name: "Voice-triggered profiles",
    icon: Mic,
    echo: true,
    wispr: false,
    superwhisper: false,
  },
  {
    name: "Context-aware profiles",
    icon: SlidersHorizontal,
    echo: true,
    wispr: false,
    superwhisper: "Limited",
  },
  {
    name: "Open source",
    icon: Code2,
    echo: true,
    wispr: false,
    superwhisper: false,
  },
];

/* ─── Icons ─── */

function Check() {
  return (
    <svg
      className="h-5 w-5 text-primary"
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
  );
}

function Cross() {
  return (
    <svg
      className="h-5 w-5 text-muted-foreground/30"
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M18 6 6 18" />
      <path d="m6 6 12 12" />
    </svg>
  );
}

function CellValue({
  value,
  isEcho = false,
}: {
  value: FeatureValue;
  isEcho?: boolean;
}) {
  if (typeof value === "boolean") {
    return value ? <Check /> : <Cross />;
  }
  if (value === "Limited") {
    return (
      <span className="text-[11px] font-medium text-muted-foreground/50 rounded-full border border-border/60 px-2 py-0.5">
        Limited
      </span>
    );
  }
  return (
    <span
      className={`text-sm font-medium ${isEcho ? "text-foreground" : "text-muted-foreground"}`}
    >
      {value}
    </span>
  );
}

/* ─── Animated table row ─── */

function AnimatedRow({
  feature,
  index,
  isLast,
  isInView,
}: {
  feature: Feature;
  index: number;
  isLast: boolean;
  isInView: boolean;
}) {
  const Icon = feature.icon;

  return (
    <motion.tr
      className={`${!isLast ? "border-b border-border/40" : ""} transition-colors hover:bg-muted/20`}
      initial={{ opacity: 0, y: 8 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.35, delay: index * 0.08, ease: "easeOut" }}
    >
      {/* Feature name + icon */}
      <td className="p-4">
        <div className="flex items-center gap-2.5">
          <Icon className="h-4 w-4 text-muted-foreground/40 flex-shrink-0" />
          <span className="text-sm font-medium">{feature.name}</span>
        </div>
      </td>

      {/* Echo value (spring-animated) */}
      <td className="bg-primary/[0.03] p-4">
        <motion.div
          className="flex items-center justify-center"
          initial={{ scale: 0.8, opacity: 0 }}
          animate={isInView ? { scale: 1, opacity: 1 } : {}}
          transition={{
            type: "spring",
            stiffness: 400,
            damping: 20,
            delay: index * 0.08 + 0.1,
          }}
        >
          {feature.isPrice ? (
            <div className="flex flex-col items-center">
              <span className="text-lg font-bold bg-gradient-to-r from-[var(--gradient-start)] to-[var(--gradient-end)] bg-clip-text text-transparent">
                Free
              </span>
              <span className="text-[10px] text-muted-foreground">
                forever
              </span>
            </div>
          ) : (
            <CellValue value={feature.echo} isEcho />
          )}
        </motion.div>
      </td>

      {/* Wispr value (fade-in, delayed) */}
      <td className="p-4">
        <motion.div
          className="flex items-center justify-center"
          initial={{ opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ duration: 0.25, delay: index * 0.08 + 0.2 }}
        >
          {feature.isPrice ? (
            <span className="text-sm text-muted-foreground">
              {feature.wispr as string}
            </span>
          ) : (
            <CellValue value={feature.wispr} />
          )}
        </motion.div>
      </td>

      {/* Superwhisper value (fade-in, delayed more) */}
      <td className="p-4">
        <motion.div
          className="flex items-center justify-center"
          initial={{ opacity: 0 }}
          animate={isInView ? { opacity: 1 } : {}}
          transition={{ duration: 0.25, delay: index * 0.08 + 0.25 }}
        >
          {feature.isPrice ? (
            <span className="text-sm text-muted-foreground">
              {feature.superwhisper as string}
            </span>
          ) : (
            <CellValue value={feature.superwhisper} />
          )}
        </motion.div>
      </td>
    </motion.tr>
  );
}

/* ─── Table body (shared inView trigger for stagger) ─── */

function ComparisonBody() {
  const ref = useRef<HTMLTableSectionElement>(null);
  const isInView = useInView(ref, { once: true, amount: 0.15 });

  return (
    <tbody ref={ref}>
      {features.map((feature, index) => (
        <AnimatedRow
          key={feature.name}
          feature={feature}
          index={index}
          isLast={index === features.length - 1}
          isInView={isInView}
        />
      ))}
    </tbody>
  );
}

/* ─── Mobile swipeable cards ─── */

const competitors = [
  {
    name: "Echo",
    price: "Free",
    isEcho: true,
    getValue: (f: Feature) => f.echo,
  },
  {
    name: "Wispr Flow",
    price: "$15/mo",
    isEcho: false,
    getValue: (f: Feature) => f.wispr,
  },
  {
    name: "Superwhisper",
    price: "$8.49/mo",
    isEcho: false,
    getValue: (f: Feature) => f.superwhisper,
  },
];

function MobileComparisonCards() {
  const scrollRef = useRef<HTMLDivElement>(null);
  const [activeIndex, setActiveIndex] = useState(0);

  const handleScroll = useCallback(() => {
    const el = scrollRef.current;
    if (!el) return;
    const index = Math.round(el.scrollLeft / el.offsetWidth);
    setActiveIndex(index);
  }, []);

  const scrollTo = useCallback((index: number) => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollTo({ left: index * el.offsetWidth, behavior: "smooth" });
  }, []);

  return (
    <div className="md:hidden">
      <BlurFade delay={0.15} inView>
        {/* Scrollable container */}
        <div
          ref={scrollRef}
          onScroll={handleScroll}
          className="flex snap-x snap-mandatory overflow-x-auto scrollbar-none -mx-6 px-6 gap-3"
        >
          {competitors.map((comp) => (
            <div
              key={comp.name}
              className="w-full flex-shrink-0 snap-center"
            >
              {comp.isEcho ? (
                <MagicCard
                  className="rounded-xl border border-primary/30"
                  gradientFrom="var(--gradient-start)"
                  gradientTo="var(--gradient-end)"
                  gradientOpacity={0.06}
                >
                  <div className="p-5">
                    <div className="mb-4 flex items-center justify-between">
                      <h3 className="text-lg font-bold text-primary">
                        {comp.name}
                      </h3>
                      <span className="rounded-full bg-primary/10 px-3 py-1 text-sm font-semibold text-primary">
                        {comp.price}
                      </span>
                    </div>
                    <div className="space-y-3">
                      {features
                        .filter((f) => !f.isPrice)
                        .map((feature) => {
                          const Icon = feature.icon;
                          return (
                            <div
                              key={feature.name}
                              className="flex items-center justify-between text-sm"
                            >
                              <div className="flex items-center gap-2">
                                <Icon className="h-3.5 w-3.5 text-muted-foreground/40" />
                                <span className="text-muted-foreground">
                                  {feature.name}
                                </span>
                              </div>
                              <CellValue value={comp.getValue(feature)} isEcho />
                            </div>
                          );
                        })}
                    </div>
                  </div>
                </MagicCard>
              ) : (
                <div className="rounded-xl border border-border p-5 h-full">
                  <div className="mb-4 flex items-center justify-between">
                    <h3 className="text-lg font-medium">{comp.name}</h3>
                    <span className="text-sm text-muted-foreground">
                      {comp.price}
                    </span>
                  </div>
                  <div className="space-y-3">
                    {features
                      .filter((f) => !f.isPrice)
                      .map((feature) => (
                        <div
                          key={feature.name}
                          className="flex items-center justify-between text-sm"
                        >
                          <span className="text-muted-foreground">
                            {feature.name}
                          </span>
                          <CellValue value={comp.getValue(feature)} />
                        </div>
                      ))}
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Dots indicator */}
        <div className="mt-4 flex justify-center gap-2">
          {competitors.map((comp, i) => (
            <button
              key={comp.name}
              onClick={() => scrollTo(i)}
              className={`h-2 rounded-full transition-all duration-300 ${
                activeIndex === i
                  ? "w-6 bg-primary"
                  : "w-2 bg-muted-foreground/20"
              }`}
              aria-label={`View ${comp.name}`}
            />
          ))}
        </div>
      </BlurFade>
    </div>
  );
}

/* ─── Section ─── */

export function Comparison() {
  return (
    <section className="relative px-6 py-20 md:py-28 overflow-hidden">
      {/* Subtle warm gradient background */}
      <div className="pointer-events-none absolute inset-0 bg-gradient-to-br from-[var(--gradient-start)]/[0.04] via-transparent to-[var(--gradient-end)]/[0.04]" />

      <div className="relative mx-auto max-w-4xl">
        {/* Heading */}
        <BlurFade delay={0.1} inView>
          <div className="mb-12 max-w-lg">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
              Same features. Zero cost.
            </h2>
            <p className="mt-4 text-muted-foreground">
              See how Echo stacks up against the paid alternatives.
            </p>
          </div>
        </BlurFade>

        {/* ── Desktop table ── */}
        <div className="hidden md:block">
          <BlurFade delay={0.15} inView>
            <div className="overflow-hidden rounded-2xl border border-border/60 bg-card/80 backdrop-blur-sm">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-border/60">
                    <th className="p-4 text-left text-xs font-medium uppercase tracking-wider text-muted-foreground/60 w-[220px]">
                      Feature
                    </th>
                    <th className="relative bg-primary/[0.03] p-4 text-center">
                      {/* Gradient indicator bar */}
                      <div className="absolute inset-x-0 top-0 h-0.5 bg-gradient-to-r from-[var(--gradient-start)] to-[var(--gradient-end)]" />
                      <div className="flex flex-col items-center gap-0.5">
                        <span className="text-sm font-bold text-primary">
                          Echo
                        </span>
                        <span className="text-[10px] font-medium text-muted-foreground/50">
                          $0
                        </span>
                      </div>
                    </th>
                    <th className="p-4 text-center">
                      <div className="flex flex-col items-center gap-0.5">
                        <span className="text-sm font-medium text-muted-foreground">
                          Wispr Flow
                        </span>
                        <span className="text-[10px] text-muted-foreground/40">
                          from $15/mo
                        </span>
                      </div>
                    </th>
                    <th className="p-4 text-center">
                      <div className="flex flex-col items-center gap-0.5">
                        <span className="text-sm font-medium text-muted-foreground">
                          Superwhisper
                        </span>
                        <span className="text-[10px] text-muted-foreground/40">
                          from $8.49/mo
                        </span>
                      </div>
                    </th>
                  </tr>
                </thead>
                <ComparisonBody />
              </table>
            </div>
          </BlurFade>
        </div>

        {/* ── Mobile cards (swipeable) ── */}
        <MobileComparisonCards />
      </div>
    </section>
  );
}

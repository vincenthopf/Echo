"use client";

import Image from "next/image";
import { BlurFade } from "@/components/ui/blur-fade";
import { Marquee } from "@/components/ui/marquee";

const testimonials = [
  {
    name: "Sarah K.",
    role: "Freelance Writer",
    quote:
      "Honestly I just wanted something that worked without sending my stuff to the cloud. Turns out it's also way more accurate than Apple dictation? Like, noticeably better.",
    avatar: "/avatars/sarah-k.png",
  },
  {
    name: "Marcus T.",
    role: "Software Engineer",
    quote:
      "The thing where it switches context based on what app you're in is wild. I'm in VS Code and it keeps my variable names intact, then I switch to Slack and it's casual again. Didn't even set it up.",
    avatar: "/avatars/marcus-t.png",
  },
  {
    name: "Priya R.",
    role: "Product Manager",
    quote:
      "I ramble through meeting notes and it just... formats them? With bullet points and action items? I used to spend 20 min cleaning up transcripts after every call.",
    avatar: "/avatars/priya-r.png",
  },
  {
    name: "James L.",
    role: "Journalist",
    quote:
      "Wait, this is free? I was paying for Otter. The local transcription is fast enough for interviews and I don't have to worry about source confidentiality.",
    avatar: "/avatars/james-l.png",
  },
  {
    name: "Elena V.",
    role: "Academic Researcher",
    quote:
      "I keep sensitive interview data on-device with local models, but switch to cloud for quick lecture notes. Having both options in one app is exactly what I needed.",
    avatar: "/avatars/elena-v.png",
  },
  {
    name: "David W.",
    role: "Content Creator",
    quote:
      "The type-out mode is so good. I dictate directly into Notion, Google Docs, whatever — it just types it out character by character like I'm actually typing. Works everywhere.",
    avatar: "/avatars/david-w.png",
  },
];

function TestimonialCard({
  name,
  role,
  quote,
  avatar,
}: (typeof testimonials)[0]) {
  return (
    <div className="mx-3 flex w-[350px] flex-col gap-4 rounded-xl border border-border bg-card p-6">
      <p className="text-sm leading-relaxed text-muted-foreground">
        &ldquo;{quote}&rdquo;
      </p>
      <div className="flex items-center gap-3">
        <Image
          src={avatar}
          alt={name}
          width={36}
          height={36}
          className="h-9 w-9 rounded-full object-cover"
        />
        <div>
          <p className="text-sm font-medium">{name}</p>
          <p className="text-xs text-muted-foreground">{role}</p>
        </div>
      </div>
    </div>
  );
}

export function Testimonials() {
  return (
    <section className="relative py-20 md:py-28">
      <div className="mx-auto max-w-6xl px-6">
        <BlurFade delay={0.1} inView>
          <div className="mb-12 max-w-lg">
            <h2 className="text-3xl font-bold tracking-tight sm:text-4xl">
              Don&apos;t take our word for it.
            </h2>
            <p className="mt-4 text-muted-foreground">
              Take theirs.
            </p>
          </div>
        </BlurFade>
      </div>

      <BlurFade delay={0.3} inView>
        <div className="relative">
          <Marquee pauseOnHover className="[--duration:40s]">
            {testimonials.map((testimonial) => (
              <TestimonialCard key={testimonial.name} {...testimonial} />
            ))}
          </Marquee>
          {/* Gradient fade edges */}
          <div className="pointer-events-none absolute inset-y-0 left-0 w-24 bg-gradient-to-r from-background to-transparent" />
          <div className="pointer-events-none absolute inset-y-0 right-0 w-24 bg-gradient-to-l from-background to-transparent" />
        </div>
      </BlurFade>
    </section>
  );
}

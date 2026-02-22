"use client";

import React, { useRef, useState } from "react";
import { motion } from "motion/react";

export interface NavLink {
  id: number;
  name: string;
  href: string;
}

interface NavMenuProps {
  links: NavLink[];
}

export function NavMenu({ links }: NavMenuProps) {
  const ref = useRef<HTMLUListElement>(null);
  const [left, setLeft] = useState(0);
  const [width, setWidth] = useState(0);
  const [isReady, setIsReady] = useState(false);
  const [activeSection, setActiveSection] = useState("");
  const [isManualScroll, setIsManualScroll] = useState(false);

  // Only hash links participate in scroll-spy
  const hashLinks = links.filter((l) => l.href.startsWith("#"));

  React.useEffect(() => {
    const firstItem = ref.current?.querySelector("li[data-nav-item]");
    if (firstItem) {
      setLeft((firstItem as HTMLElement).offsetLeft);
      setWidth(firstItem.getBoundingClientRect().width);
      setIsReady(true);
    }
  }, []);

  React.useEffect(() => {
    let rafId = 0;
    const handleScroll = () => {
      if (rafId) return;
      rafId = requestAnimationFrame(() => {
        rafId = 0;
        if (isManualScroll) return;
        let closestSection = "";
        let minDistance = Infinity;
        for (const link of hashLinks) {
          const sectionId = link.href.substring(1);
          const element = document.getElementById(sectionId);
          if (element) {
            const rect = element.getBoundingClientRect();
            const distance = Math.abs(rect.top - 100);
            if (distance < minDistance) {
              minDistance = distance;
              closestSection = link.href;
            }
          }
        }
        if (closestSection && closestSection !== activeSection) {
          setActiveSection(closestSection);
          const navItem = ref.current?.querySelector(
            `[data-href="${closestSection}"]`
          );
          if (navItem) {
            setLeft((navItem as HTMLElement).offsetLeft);
            setWidth(navItem.getBoundingClientRect().width);
          }
        }
      });
    };
    window.addEventListener("scroll", handleScroll, { passive: true });
    handleScroll();
    return () => {
      window.removeEventListener("scroll", handleScroll);
      if (rafId) cancelAnimationFrame(rafId);
    };
  }, [isManualScroll, activeSection, hashLinks]);

  const handleClick = (
    e: React.MouseEvent<HTMLAnchorElement>,
    link: NavLink
  ) => {
    // Regular links (like /docs) navigate normally
    if (!link.href.startsWith("#")) return;

    e.preventDefault();
    const targetId = link.href.substring(1);
    const element = document.getElementById(targetId);
    if (element) {
      setIsManualScroll(true);
      setActiveSection(link.href);
      const navItem = (e.currentTarget.parentElement as HTMLElement) || null;
      if (navItem) {
        setLeft(navItem.offsetLeft);
        setWidth(navItem.getBoundingClientRect().width);
      }
      const offsetPosition =
        element.getBoundingClientRect().top + window.pageYOffset - 100;
      window.scrollTo({ top: offsetPosition, behavior: "smooth" });
      setTimeout(() => setIsManualScroll(false), 500);
    }
  };

  return (
    <div className="hidden w-full md:block">
      <ul
        className="relative mx-auto flex h-11 w-fit items-center justify-center rounded-full px-2"
        ref={ref}
      >
        {links.map((link) => (
          <li
            key={link.id}
            data-nav-item
            data-href={link.href}
            className={`z-10 flex h-full cursor-pointer items-center justify-center px-4 py-2 text-sm font-medium tracking-tight transition-colors duration-200 ${
              activeSection === link.href
                ? "text-foreground"
                : "text-foreground/60 hover:text-foreground"
            }`}
          >
            <a href={link.href} onClick={(e) => handleClick(e, link)}>
              {link.name}
            </a>
          </li>
        ))}
        {isReady && (
          <motion.li
            animate={{ left, width }}
            transition={{ type: "spring", stiffness: 400, damping: 30 }}
            className="absolute inset-0 my-1.5 rounded-full border border-border bg-accent/60"
          />
        )}
      </ul>
    </div>
  );
}

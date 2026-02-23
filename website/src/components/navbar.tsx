"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Menu, X, Download } from "lucide-react";
import { AnimatePresence, motion, useScroll } from "motion/react";
import { cn } from "@/lib/utils";
import { NavMenu, type NavLink } from "@/components/nav-menu";
import { ThemeToggle } from "@/components/theme-toggle";

const INITIAL_WIDTH = "70rem";
const SCROLLED_WIDTH = "800px";

const navLinks: NavLink[] = [
  { id: 1, name: "Features", href: "#features" },
  { id: 2, name: "Pricing", href: "#pricing" },
  { id: 3, name: "Docs", href: "/docs" },
];

const overlayVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
  exit: { opacity: 0 },
};

const drawerVariants = {
  hidden: { opacity: 0, y: 100 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      type: "spring" as const,
      damping: 15,
      stiffness: 200,
      staggerChildren: 0.03,
    },
  },
  exit: {
    opacity: 0,
    y: 100,
    transition: { duration: 0.1 },
  },
};

const drawerMenuContainerVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
};

const drawerMenuVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
};

export function Navbar() {
  const { scrollY } = useScroll();
  const [hasScrolled, setHasScrolled] = useState(false);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  useEffect(() => {
    const unsubscribe = scrollY.on("change", (latest) => {
      setHasScrolled(latest > 10);
    });
    return unsubscribe;
  }, [scrollY]);

  const toggleDrawer = () => setIsDrawerOpen((prev) => !prev);
  const handleOverlayClick = () => setIsDrawerOpen(false);

  return (
    <header
      className={cn(
        "sticky z-50 mx-4 flex justify-center transition-all duration-300 md:mx-0",
        hasScrolled ? "top-6" : "top-4 mx-0"
      )}
    >
      <motion.div
        initial={{ width: INITIAL_WIDTH }}
        animate={{ width: hasScrolled ? SCROLLED_WIDTH : INITIAL_WIDTH }}
        transition={{ duration: 0.3, ease: [0.25, 0.1, 0.25, 1] }}
        style={{ maxWidth: "100%" }}
      >
        <div
          className={cn(
            "mx-auto max-w-7xl rounded-2xl transition-all duration-300 xl:px-0",
            hasScrolled
              ? "border border-border bg-background/75 px-2 backdrop-blur-lg"
              : "bg-background px-7"
          )}
        >
          <div className="flex h-[56px] items-center justify-between p-4">
            {/* Logo */}
            <Link href="/" className="flex shrink-0 items-center gap-2.5">
              <Image
                src="/app-icon.webp"
                alt="Echo"
                width={28}
                height={28}
                className="size-7 rounded-md"
                priority
              />
              <span className="text-lg font-semibold text-foreground">
                Echo
              </span>
            </Link>

            {/* Desktop nav */}
            <NavMenu links={navLinks} />

            {/* Right side: CTA + theme toggle + mobile menu */}
            <div className="flex shrink-0 items-center gap-1 md:gap-3">
              <Link
                href="/download"
                className="hidden h-8 items-center justify-center gap-1.5 rounded-full bg-primary px-4 text-sm font-medium text-primary-foreground shadow-sm transition-all hover:bg-primary/90 active:scale-95 md:inline-flex"
              >
                <Download className="size-3.5" />
                Download
              </Link>
              <ThemeToggle />
              <button
                className="flex size-8 cursor-pointer items-center justify-center rounded-md border border-border md:hidden"
                onClick={toggleDrawer}
                aria-label={isDrawerOpen ? "Close menu" : "Open menu"}
              >
                {isDrawerOpen ? (
                  <X className="size-5" />
                ) : (
                  <Menu className="size-5" />
                )}
              </button>
            </div>
          </div>
        </div>
      </motion.div>

      {/* Mobile drawer */}
      <AnimatePresence>
        {isDrawerOpen && (
          <>
            <motion.div
              className="fixed inset-0 bg-black/50 backdrop-blur-sm"
              initial="hidden"
              animate="visible"
              exit="exit"
              variants={overlayVariants}
              transition={{ duration: 0.2 }}
              onClick={handleOverlayClick}
            />
            <motion.div
              className="fixed inset-x-0 bottom-3 z-50 mx-auto w-[95%] rounded-xl border border-border bg-background p-4 shadow-lg"
              initial="hidden"
              animate="visible"
              exit="exit"
              variants={drawerVariants}
            >
              <div className="flex flex-col gap-4">
                <div className="flex items-center justify-between">
                  <Link
                    href="/"
                    className="flex items-center gap-2.5"
                    onClick={() => setIsDrawerOpen(false)}
                  >
                    <Image
                      src="/app-icon.webp"
                      alt="Echo"
                      width={28}
                      height={28}
                      className="size-7 rounded-md"
                      priority
                    />
                    <span className="text-lg font-semibold text-foreground">
                      Echo
                    </span>
                  </Link>
                  <button
                    onClick={toggleDrawer}
                    className="cursor-pointer rounded-md border border-border p-1"
                    aria-label="Close menu"
                  >
                    <X className="size-5" />
                  </button>
                </div>
                <motion.ul
                  className="mb-2 flex flex-col rounded-md border border-border text-sm"
                  variants={drawerMenuContainerVariants}
                >
                  <AnimatePresence>
                    {navLinks.map((item) => (
                      <motion.li
                        key={item.id}
                        className="border-b border-border p-2.5 last:border-b-0"
                        variants={drawerMenuVariants}
                      >
                        <a
                          href={item.href}
                          onClick={(e) => {
                            if (item.href.startsWith("#")) {
                              e.preventDefault();
                              document
                                .getElementById(item.href.substring(1))
                                ?.scrollIntoView({ behavior: "smooth" });
                            }
                            setIsDrawerOpen(false);
                          }}
                          className="text-foreground/80 transition-colors hover:text-foreground"
                        >
                          {item.name}
                        </a>
                      </motion.li>
                    ))}
                  </AnimatePresence>
                </motion.ul>
                <Link
                  href="/download"
                  onClick={() => setIsDrawerOpen(false)}
                  className="flex h-10 w-full items-center justify-center gap-1.5 rounded-full bg-primary text-sm font-medium text-primary-foreground transition-all hover:bg-primary/90 active:scale-95"
                >
                  <Download className="size-3.5" />
                  Download for Mac
                </Link>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </header>
  );
}

import { createMDX } from 'fumadocs-mdx/next';

/** @type {import('next').NextConfig} */
const config = {
  images: {
    unoptimized: true,
  },
};

const withMDX = createMDX();

export default withMDX(config);

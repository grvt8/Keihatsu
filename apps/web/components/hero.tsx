"use client";

import Image from "next/image";
import { useState } from "react";
import { Blobatar } from "@blobatar/react";
import { ArrowBendDownLeftIcon } from "@phosphor-icons/react/ssr";
import "blobatar/motion.css";

const downloadUrl =
  "https://github.com/grvt8/Keihatsu/releases/download/v1.0.0/keihatsu-v1.0.0.apk";

const carouselPages = [
  {
    label: "Manga details",
    src: "/mockups/mangadetails.png",
    alt: "Keihatsu manga details screen",
  },
  {
    label: "Library",
    src: "/mockups/library.png",
    alt: "Keihatsu library screen",
  },
  {
    label: "Profile",
    src: "/mockups/profile.png",
    alt: "Keihatsu profile screen",
  },
  {
    label: "History",
    src: "/mockups/history.png",
    alt: "Keihatsu reading history screen",
  },
  {
    label: "Extensions",
    src: "/mockups/plugins.png",
    alt: "Keihatsu extensions screen",
  },
];

export function Hero() {
  const [activeIndex, setActiveIndex] = useState(1);
  const previousIndex =
    (activeIndex - 1 + carouselPages.length) % carouselPages.length;
  const nextIndex = (activeIndex + 1) % carouselPages.length;

  return (
    <section id="reader" className="paper-hero">
      <div className="paper-shell paper-hero__content">
        <div className="paper-hero__copy">
          <div className="eyebrow-pill">
            <span />
            Open-source manga reader
          </div>
          <h1>
            Your next chapter,
            <br />
            without the hunt.
          </h1>
          <p>
            Search across extensions, save chapters offline, sync across devices
            and settle into a reader that keeps the story at the center.
          </p>
          <div className="paper-hero__actions">
            <a className="pill-button pill-button--large" href={downloadUrl} download>
              <span aria-hidden="true">↓</span>
              Download for Android
            </a>
            <a
              className="pill-button pill-button--large pill-button--secondary"
              href="https://github.com/grvt8/Keihatsu"
            >
              View on GitHub ↗
            </a>
          </div>
        </div>

        <div className="hero-social hero-social--search" aria-hidden="true">
          <Blobatar
            className="hero-blobatar"
            name="extension-reader"
            hue={112}
            tone={0.54}
            background="squircle"
            animate="hover"
          />
          <span>One search. Every source.</span>
        </div>

        <div className="hero-social hero-social--offline" aria-hidden="true">
          <span>Offline ready ↓</span>
          <Blobatar
            className="hero-blobatar"
            name="offline-reader"
            hue={38}
            tone={0.42}
            background="squircle"
            animate="hover"
          />
        </div>

        <div className="hero-carousel" aria-label="Keihatsu app screen carousel">
          <button
            className="hero-carousel__slide hero-carousel__slide--previous"
            type="button"
            onClick={() => setActiveIndex(previousIndex)}
            aria-label={`Show ${carouselPages[previousIndex].label}`}
          >
            <Image
              src={carouselPages[previousIndex].src}
              alt={carouselPages[previousIndex].alt}
              fill
              sizes="291px"
              priority
            />
          </button>

          <div className="hero-carousel__annotation" aria-live="polite">
            <ArrowBendDownLeftIcon size={54} weight="bold" aria-hidden="true" />
            <span>
              <i />
              {carouselPages[activeIndex].label}
            </span>
          </div>

          <button
            className="hero-carousel__slide hero-carousel__slide--active"
            type="button"
            onClick={() => setActiveIndex(nextIndex)}
            aria-label={`${carouselPages[activeIndex].label} is active. Show ${carouselPages[nextIndex].label}`}
          >
            <Image
              src={carouselPages[activeIndex].src}
              alt={carouselPages[activeIndex].alt}
              fill
              sizes="291px"
              priority
            />
          </button>

          <button
            className="hero-carousel__slide hero-carousel__slide--next"
            type="button"
            onClick={() => setActiveIndex(nextIndex)}
            aria-label={`Show ${carouselPages[nextIndex].label}`}
          >
            <Image
              src={carouselPages[nextIndex].src}
              alt={carouselPages[nextIndex].alt}
              fill
              sizes="291px"
              priority
            />
          </button>
        </div>
      </div>

      <div className="feature-tape" aria-label="Product highlights">
        <span>EXTENSION SEARCH</span>
        <i>✦</i>
        <span>OFFLINE CHAPTERS</span>
        <i>✦</i>
        <span>FOCUS-FIRST READER</span>
        <i>✦</i>
        <span>OPEN SOURCE</span>
      </div>
    </section>
  );
}

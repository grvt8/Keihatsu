"use client";

import Image from "next/image";
import { useCallback, useEffect, useRef, useState } from "react";
import { Blobatar } from "@blobatar/react";
import useEmblaCarousel from "embla-carousel-react";
import "blobatar/motion.css";

const downloadUrl =
  "https://github.com/grvt8/Keihatsu/releases/download/v1.0.0/keihatsu-v1.0.0.apk";

const carouselDelay = 2500;

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

function CarouselArrow() {
  return (
    <svg
      viewBox="533 0 81 55"
      width="81"
      height="55"
      xmlns="http://www.w3.org/2000/svg"
      style={{ rotate: "320.49deg", transformOrigin: "70% 20%" }}
      aria-hidden="true"
    >
      <path
        d="M599.96 45.944C586.455 44.766 583.694 43.551 575.429 39.51C567.384 35.918 566.723 26.041 572.674 22.898C577.522 20.204 579.286 28.061 573.997 31.877C568.486 35.469 558.568 33.224 552.617 30.306C549.751 28.959 544.326 25.978 542.343 20.141"
        fill="none"
        stroke="#111111"
        strokeWidth="3"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M548.81 15.446L535.508 11.779L538.66 26.477"
        fill="none"
        stroke="#F4CB00"
        strokeWidth="3"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

export function Hero() {
  const [activeIndex, setActiveIndex] = useState(1);
  const autoplayTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [carouselRef, carouselApi] = useEmblaCarousel({
    align: "center",
    duration: 20,
    loop: true,
    startIndex: 1,
    watchDrag: false,
  });

  const stopAutoplay = useCallback(() => {
    if (autoplayTimer.current) {
      clearTimeout(autoplayTimer.current);
      autoplayTimer.current = null;
    }
  }, []);

  const scheduleAutoplay = useCallback(() => {
    stopAutoplay();

    if (!carouselApi || document.hidden) return;

    autoplayTimer.current = setTimeout(() => {
      carouselApi.scrollNext();
    }, carouselDelay);
  }, [carouselApi, stopAutoplay]);

  useEffect(() => {
    if (!carouselApi) return;

    const syncSelectedPage = () => {
      setActiveIndex(carouselApi.selectedScrollSnap());
    };
    const handleSettle = () => {
      syncSelectedPage();
      scheduleAutoplay();
    };
    const handleVisibilityChange = () => {
      if (document.hidden) stopAutoplay();
      else scheduleAutoplay();
    };

    syncSelectedPage();
    scheduleAutoplay();
    carouselApi.on("select", syncSelectedPage);
    carouselApi.on("reInit", syncSelectedPage);
    carouselApi.on("settle", handleSettle);
    document.addEventListener("visibilitychange", handleVisibilityChange);

    return () => {
      stopAutoplay();
      carouselApi.off("select", syncSelectedPage);
      carouselApi.off("reInit", syncSelectedPage);
      carouselApi.off("settle", handleSettle);
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [carouselApi, scheduleAutoplay, stopAutoplay]);

  return (
    <section id="reader" className="paper-hero">
      <div className="paper-shell paper-hero__content">
        <div className="paper-hero__copy">
          <div className="eyebrow-pill">
            <span />
            Open-source manga reader
          </div>
          <h1 className="tracking-tighter">
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
          <div className="hero-blobatar-shell hero-blobatar-shell--search">
            <Blobatar
              className="hero-blobatar"
              name="recovered-nub"
              size={100}
              background={false}
              animate="always"
              hue={140}
              tone={0.7}
              traits={{
                shape: 0.75,
                "body.r": 0.53,
                "body.ratio": 0.278,
                "body.x": 0.3067,
                "body.y": 0.5867,
                "body.n": 0.63,
                "nub.n": 0,
                "nub.a0": 0.4659,
                "nub.r0": 0.8367,
                "eye.rx": 0.6456,
                "eye.ratio": 0.7154,
                "eye.scale": 0.7542,
                "eye.stretch": 0.7786,
                "eye.gap": 0.2945,
                "eye.n": 0.161,
                "eye.dy": 0.5191,
                "eye.lean": 0.5994,
                "eye.lean2": 0.9035,
                "gaze.x": 0.9324,
                "gaze.y": 0.9349,
              }}
            />
          </div>
          <span>One search. Every source.</span>
        </div>

        <div className="hero-social hero-social--offline" aria-hidden="true">
          <span>Offline ready ↓</span>
          <div className="hero-blobatar-shell hero-blobatar-shell--offline">
            <Blobatar
              className="hero-blobatar"
              name="recovered-cloud"
              width={105}
              height={99}
              preserveAspectRatio="none"
              background={false}
              animate="always"
              palette={{
                head: "#FFDAA0",
                eye: "#140E06",
              }}
              traits={{
                shape: 0.82,
                "body.r": 0.4469,
                "body.ratio": 0.5188,
                "body.x": 0.4567,
                "body.y": 0.5933,
                "body.pts": 0.9,
                "body.r0": 0.2159,
                "body.r1": 0.3829,
                "body.r2": 0.4017,
                "body.r3": 0.1649,
                "body.r4": 0.1819,
                "body.r5": 0.9117,
                "body.r6": 0.2613,
                "body.r7": 0.1367,
                "cloud.n": 0,
                "cloud.r0": 0.5535,
                "cloud.r1": 0.3346,
                "cloud.r2": 0.8117,
                "cloud.r3": 0.1837,
                "eye.rx": 0.8119,
                "eye.ratio": 0.4038,
                "eye.scale": 0.6367,
                "eye.stretch": 0.5399,
                "eye.gap": 0.8919,
                "eye.n": 0.9,
                "eye.dy": 0.9337,
                "eye.lean": 0.3394,
                "eye.lean2": 0.0546,
                "gaze.x": 0.0097,
                "gaze.y": 0.2257,
              }}
            />
          </div>
        </div>

        <div className="hero-carousel" aria-label="Keihatsu app screen carousel">
          <div className="hero-carousel__annotation" aria-live="polite">
            <CarouselArrow />
            <span>
              <i />
              {carouselPages[activeIndex].label}
            </span>
          </div>

          <div className="hero-carousel__viewport" ref={carouselRef}>
            <div className="hero-carousel__track">
              {carouselPages.map((page, index) => {
                const isActive = index === activeIndex;
                const distance = Math.abs(index - activeIndex);
                const isNeighbor =
                  distance === 1 || distance === carouselPages.length - 1;

                return (
                  <div className="hero-carousel__item" key={page.label}>
                    <button
                      className={`hero-carousel__slide ${
                        isActive
                          ? "hero-carousel__slide--active"
                          : `hero-carousel__slide--inactive ${
                              isNeighbor ? "" : "hero-carousel__slide--hidden"
                            }`
                      }`}
                      type="button"
                      onClick={() => carouselApi?.scrollTo(index)}
                      aria-current={isActive ? "true" : undefined}
                      aria-label={
                        isActive ? `${page.label} is active` : `Show ${page.label}`
                      }
                    >
                      <Image
                        src={page.src}
                        alt={page.alt}
                        fill
                        sizes="291px"
                        priority={index < 3}
                        draggable={false}
                      />
                    </button>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      <div className="feature-tape" aria-label="Product highlights">
        <span>MULTI-EXTENSION SEARCH</span>
        <i>✦</i>
        <span>OFFLINE CHAPTERS</span>
        <i>✦</i>
        <span>IMMERSIVE READER</span>
        <i>✦</i>
        <span>OPEN SOURCE</span>
      </div>
    </section>
  );
}

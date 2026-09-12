import Image from "next/image";
import {
  ArrowUpRightIcon,
  MagnifyingGlassIcon,
} from "@phosphor-icons/react/ssr";
import { ReaderAvatar } from "@/components/reader-avatar";

const extensionResults = [
  {
    name: "ManhuaTop",
    count: "28 results",
    tone: "neutral",
    image: "/manhuatop.jpeg",
  },
  {
    name: "Weebcentral",
    count: "19 results",
    tone: "lilac",
    image: "/weebcentral.png",
  },
  {
    name: "MangaFire",
    count: "13 results",
    tone: "sky",
    image: "/mangafire.png",
  },
];

export function BentoFeatures() {
  return (
    <section id="features" className="paper-bento">
      <div className="paper-shell">
        <header className="section-heading section-heading--split">
          <div>
            <p className="section-kicker">Built for the long read</p>
            <h2>
              Everything you need.
              <br />
              Nothing in the way.
            </h2>
          </div>
          <p className="section-intro">
            A reader that moves quickly when you want more and disappears when
            you&apos;re already in the story.
          </p>
        </header>

        <div className="bento-grid">
          <article className="bento-card bento-card--search">
            <div className="bento-card__copy">
              <p className="bento-label">01 — SEARCH</p>
              <h3>
                Every source,
                <br />
                one search bar.
              </h3>
              <p>
                Search across your installed extensions without digging through
                repos first.
              </p>
            </div>
            <div className="bento-card__foot">
              <span className="round-arrow">
                <ArrowUpRightIcon size={18} weight="bold" aria-hidden="true" />
              </span>
              <strong>Fewer taps to chapter one</strong>
            </div>
            <div className="extension-card" aria-hidden="true">
              <div className="extension-search">
                <MagnifyingGlassIcon size={18} weight="bold" />
                <span>Search all extensions</span>
              </div>
              {extensionResults.map((extension) => (
                <div
                  key={extension.name}
                  className="extension-row"
                  data-tone={extension.tone}
                >
                  <span className="extension-row__identity">
                    <Image
                      src={extension.image}
                      alt=""
                      width={42}
                      height={42}
                    />
                    <strong>{extension.name}</strong>
                  </span>
                  <strong>{extension.count}</strong>
                </div>
              ))}
            </div>
          </article>

          <article className="bento-card bento-card--reader">
            <div className="bento-card__copy">
              <p className="bento-label">02 — READER</p>
              <h3>
                Let the panels
                <br />
                take over.
              </h3>
              <p>Controls stay close, then fade when the reading starts.</p>
            </div>
            <span className="round-arrow">↘</span>
            <div className="reader-card__phone" aria-hidden="true">
              <Image
                src="/mockups/readerScreen.png"
                alt=""
                fill
                sizes="190px"
              />
            </div>
          </article>

          <article className="bento-card bento-card--offline">
            <div className="bento-card__copy">
              <p className="bento-label">03 — OFFLINE</p>
              <h3>Your library goes too.</h3>
              <p>
                Queue chapters once. Read on the train, in the air, or wherever
                signal gives up.
              </p>
            </div>
            <div className="download-row">
              <span>↓</span>
              <strong>Chapter 158</strong>
              <strong>92%</strong>
            </div>
          </article>

          <article className="bento-card bento-card--themes">
            <div className="bento-card__copy">
              <p className="bento-label">04 — THEMES</p>
              <h3>Tune the room.</h3>
              <p>Font, color, spacing...make the reader feel like yours.</p>
            </div>
            <div className="theme-swatches" aria-hidden="true">
              <span />
              <span />
              <span />
              <span />
            </div>
          </article>

          <article className="bento-card bento-card--social">
            <div className="bento-card__copy">
              <p className="bento-label">05 — SOCIAL READING</p>
              <h3>
                Talk between
                <br />
                the panels.
              </h3>
              <p>
                Comment in the app and connect with fellow readers around the
                manga you love.
              </p>
            </div>
            <div className="mini-thread" aria-label="Reader comment preview">
              <div className="mini-thread__row">
                <span className="reader-avatar reader-avatar--triangle">
                  <ReaderAvatar variant="triangle" />
                </span>
                <strong>That final panel... wow.</strong>
              </div>
              <div className="mini-thread__row mini-thread__row--reply">
                <strong>Chapter 159 theories?</strong>
                <span className="reader-avatar reader-avatar--drop">
                  <ReaderAvatar variant="drop" />
                </span>
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>
  );
}

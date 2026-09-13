import { ReaderAvatar } from "@/components/reader-avatar";

export function CommunitySection() {
  return (
    <section id="community" className="paper-community">
      <div className="paper-shell">
        <header className="section-heading section-heading--split section-heading--dark">
          <div>
            <p className="section-kicker">A social reader, on your terms</p>
            <h2 className="font-comic tracking-tight">
              Read together.
              <br />
              Build together.
            </h2>
          </div>
          <p className="section-intro">
            Comments stay beside the chapter, while Discord and GitHub keep the
            wider conversation open.
          </p>
        </header>

        <div className="community-grid">
          <article className="discord-card">
            <div>
              <p className="bento-label">DISCORD COMMUNITY</p>
              <h3 className="tracking-tight">
                The after-chapter
                <br />
                conversation lives here.
              </h3>
            </div>
            <a className="pill-button pill-button--community" href="https://discord.gg/8cu84svT">
              Join the Discord ↗
            </a>

            <div className="comment-cluster" aria-label="Community comment preview">
              <div className="comment comment--one">
                <span className="reader-avatar reader-avatar--triangle">
                  <ReaderAvatar variant="triangle" />
                </span>
                <p>When do y&apos;all think Brent will drop the next season?</p>
              </div>
              <div className="comment comment--two">
                <span className="reader-avatar reader-avatar--drop">
                  <ReaderAvatar variant="drop" />
                </span>
                <p>Kagurabachi is peak🔥</p>
              </div>
              <div className="comment comment--three">
                <span className="reader-avatar reader-avatar--capsule">
                  <ReaderAvatar variant="capsule" />
                </span>
                <p>Does anyone have recommendations?</p>
              </div>
            </div>
          </article>

          <article id="opensource" className="open-source-card">
            <div className="open-source-card__top">
              <p className="bento-label">OPEN SOURCE</p>
              <span>MIT LICENSE</span>
            </div>
            <div>
              <h3 className="tracking-tight">
                Inspect every line.
                <br />
                Improve the next one.
              </h3>
              <p>
                Keihatsu is transparent by default—from reader polish to
                extension behavior.
              </p>
            </div>
            <a
              className="open-source-card__footer"
              href="https://github.com/grvt8/Keihatsu"
            >
              <span>Issues · Pull requests · Releases</span>
              <i>↗</i>
            </a>
          </article>
        </div>
      </div>
    </section>
  );
}

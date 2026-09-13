import Image from "next/image";

export function EditorialSections() {
  return (
    <section className="paper-story">
      <div className="paper-shell">
        <header className="section-heading section-heading--centered">
          <p className="section-kicker">From urge to offline shelf</p>
          <h2 className="font-comic tracking-tight">
            Three small steps.
            <br />
            One uninterrupted story.
          </h2>
          <p className="section-intro">
            Keihatsu stays useful around the chapter, then gets quiet when the
            chapter begins.
          </p>
        </header>

        <div className="story-layout">
          <div className="story-steps">
            <article className="story-step story-step--active">
              <span className="story-step__bar" />
              <div>
                <small>01</small>
                <h3 className="font-comic tracking-tight">
                  Search before the urge fades
                </h3>
                <p>
                  Ask every installed extension at once and jump straight into
                  the version you want.
                </p>
              </div>
            </article>
            <article className="story-step">
              <span className="story-step__bar" />
              <div>
                <small>02</small>
                <h3 className="font-comic tracking-tight">
                  Read in a quieter room
                </h3>
              </div>
            </article>
            <article className="story-step">
              <span className="story-step__bar" />
              <div>
                <small>03</small>
                <h3 className="font-comic tracking-tight">
                  Keep the chapter close
                </h3>
              </div>
            </article>
          </div>

          <div className="platform-stage">
            <div className="platform-stage__toolbar">
              <strong>Keihatsu / One library, every device</strong>
              <span>
                <i />
                Synced
              </span>
            </div>
            <span className="platform-stage__ring platform-stage__ring--left" />
            <span className="platform-stage__ring platform-stage__ring--right" />
            <div className="platform-phone platform-phone--android">
              <Image
                src="/mockups/android.jpeg"
                alt="Keihatsu Android library"
                fill
                sizes="254px"
              />
            </div>
            <div className="platform-phone platform-phone--ios">
              <Image
                src="/mockups/ios.png"
                alt="Keihatsu iOS library"
                fill
                sizes="278px"
              />
            </div>
            <span className="platform-stage__badge">iOS + Android</span>
          </div>
        </div>
      </div>
    </section>
  );
}

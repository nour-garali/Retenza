export function Minimal() {
  return (
    <div
      className="min-h-screen w-full flex items-center justify-center"
      style={{ background: "#FBF8F6" }}
    >
      <div
        className="relative w-full h-screen flex flex-col overflow-hidden"
        style={{ fontFamily: "'Inter', sans-serif" }}
      >
        <div
          className="absolute -top-24 -right-24 w-72 h-72 rounded-full opacity-[0.06]"
          style={{ background: "radial-gradient(circle, #D73E26 0%, transparent 70%)" }}
        />

        <div className="flex-1 flex flex-col px-8 pt-16 pb-10">
          <div className="flex-1 flex flex-col items-center justify-center">
            <div
              className="w-20 h-20 rounded-[26px] flex items-center justify-center mb-10"
              style={{
                background: "linear-gradient(135deg, #E24A30 0%, #A82C18 100%)",
                boxShadow: "0 16px 32px -8px rgba(215,62,38,0.35)",
              }}
            >
              <svg width="34" height="34" viewBox="0 0 24 24" fill="none">
                <path
                  d="M12 2L14.5 8.5L21 9.5L16.5 14L17.8 20.5L12 17.3L6.2 20.5L7.5 14L3 9.5L9.5 8.5L12 2Z"
                  fill="white"
                />
              </svg>
            </div>

            <h1
              className="text-center leading-[1.12] mb-4"
              style={{
                fontFamily: "'Bricolage Grotesque', sans-serif",
                fontSize: "34px",
                fontWeight: 800,
                letterSpacing: "-1.2px",
                color: "#18110C",
              }}
            >
              Votre fidélité,
              <br />
              enfin récompensée.
            </h1>

            <p
              className="text-center max-w-[280px]"
              style={{
                fontSize: "15.5px",
                lineHeight: 1.6,
                color: "#8A7A70",
                fontWeight: 400,
              }}
            >
              Cumulez des points et débloquez des avantages, automatiquement.
            </p>
          </div>

          <div className="flex flex-col gap-3 mt-10">
            <button
              className="h-[58px] rounded-[18px] text-white font-semibold text-[16px] transition-transform active:scale-[0.98]"
              style={{
                background: "#D73E26",
                boxShadow: "0 12px 24px -8px rgba(215,62,38,0.4)",
                letterSpacing: "0.1px",
              }}
            >
              Créer un compte
            </button>

            <button
              className="h-[58px] rounded-[18px] font-semibold text-[16px] transition-transform active:scale-[0.98]"
              style={{
                background: "transparent",
                color: "#18110C",
                letterSpacing: "0.1px",
              }}
            >
              Se connecter
            </button>
          </div>

          <button
            className="mt-8 text-center text-[13.5px] font-medium"
            style={{ color: "#B7A99F" }}
          >
            Vous avez un commerce ?{" "}
            <span style={{ color: "#D73E26", fontWeight: 600 }}>
              Rejoindre en tant que partenaire
            </span>
          </button>
        </div>
      </div>
    </div>
  );
}

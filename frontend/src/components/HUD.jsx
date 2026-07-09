export default function HUD({ levelName, questionProgress, timeLeft, score, lives }) {
    return (
        <header className="hud">
            <div className="hud-stat">
                <span className="hud-value">{levelName}</span>
                <span className="hud-label">Nível</span>
            </div>
            <div className="hud-divider" />
            <div className="hud-stat">
                <span className="hud-value">{questionProgress}</span>
                <span className="hud-label">Questão</span>
            </div>
            <div className="hud-divider" />
            <div className="hud-stat">
                <span className={`hud-value hud-time${timeLeft <= 5 ? ' hud-time--urgent' : ''}`}>{timeLeft}s</span>
                <span className="hud-label">Tempo</span>
            </div>
            <div className="hud-divider" />
            <div className="hud-stat">
                <span className="hud-value hud-score">{score}</span>
                <span className="hud-label">Pontos</span>
            </div>
            <div className="hud-divider" />
            <div className="hud-stat">
                <span className="hud-value hud-lives">{lives}</span>
                <span className="hud-label">Vidas</span>
            </div>
        </header>
    );
}

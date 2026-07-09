import { useNavigate } from 'react-router-dom';
import { useGame } from '../context/GameContext.jsx';

function getClassification(accuracy) {
    if (accuracy >= 90) return { label: 'Medalha de Ouro',   message: 'Desempenho excepcional!', tier: 'ouro' };
    if (accuracy >= 70) return { label: 'Medalha de Prata',  message: 'Bom trabalho, continue evoluindo.', tier: 'prata' };
    if (accuracy >= 50) return { label: 'Medalha de Bronze', message: 'Você está no caminho certo.', tier: 'bronze' };
    return { label: 'Continue Praticando', message: 'Cada erro é um aprendizado.', tier: 'novato' };
}

export default function Report() {
    const { reportData } = useGame();
    const navigate = useNavigate();

    const { score, totalAnswered, correctAnswers, levelName } = reportData;
    const accuracy = totalAnswered > 0 ? Math.round((correctAnswers / totalAnswered) * 100) : 0;
    const { label, message, tier } = getClassification(accuracy);

    return (
        <div className="report-page">
            <div className="report-container">
                <div className="report-header">
                    <h1>Relatório de Desempenho</h1>
                    <p className="report-subtitle">Resumo do seu desempenho</p>
                </div>

                <div className={`report-badge report-badge--${tier}`}>
                    <span className="report-badge-label">{label}</span>
                    <span className="report-badge-message">{message}</span>
                </div>

                <div className="report-stats">
                    <div className="report-stat">
                        <span className="report-stat-value">{score}</span>
                        <span className="report-stat-label">Pontuação</span>
                    </div>
                    <div className="report-stat">
                        <span className="report-stat-value">{accuracy}%</span>
                        <span className="report-stat-label">Aproveitamento</span>
                    </div>
                    <div className="report-stat">
                        <span className="report-stat-value">{correctAnswers}/{totalAnswered}</span>
                        <span className="report-stat-label">Acertos</span>
                    </div>
                </div>

                <div className="report-level-row">
                    <span className="report-level-key">Nível jogado</span>
                    <span className="report-level-val">{levelName}</span>
                </div>

                <div className="report-actions">
                    <button className="btn btn-start" onClick={() => navigate('/select-difficulty')}>
                        Jogar Novamente
                    </button>
                    <button className="btn btn-about" onClick={() => navigate('/')}>
                        Voltar ao Menu
                    </button>
                </div>
            </div>
        </div>
    );
}

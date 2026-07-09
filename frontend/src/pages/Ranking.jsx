import { useNavigate } from 'react-router-dom';
import { useGame } from '../context/GameContext.jsx';
import RankingTable from '../components/RankingTable.jsx';

export default function Ranking() {
    const { rankings, clearRankings } = useGame();
    const navigate = useNavigate();

    function handleClear() {
        if (window.confirm('Tem certeza que deseja limpar o ranking?')) {
            clearRankings();
        }
    }

    return (
        <div className="ranking-page">
            <div className="ranking-container">
                <div className="ranking-header">
                    <h1>Ranking</h1>
                    <p className="ranking-subtitle">Os melhores jogadores do BNCC Play</p>
                </div>

                <RankingTable rankings={rankings} />

                <div className="ranking-actions">
                    <button className="btn btn-start" onClick={() => navigate('/select-difficulty')}>
                        Jogar
                    </button>
                    <button className="btn btn-danger" onClick={handleClear}>
                        Limpar Ranking
                    </button>
                    <button className="btn btn-about" onClick={() => navigate('/')}>
                        Menu
                    </button>
                </div>
            </div>
        </div>
    );
}

import { useNavigate } from 'react-router-dom';
import { useGame } from '../context/GameContext.jsx';
import LevelCard from '../components/LevelCard.jsx';

const levelConfigs = {
    facil: {
        levelName: 'Fácil',
        totalQuestions: 5,
        timePerQuestion: 30,
        lives: 5,
        poolSize: 10,
        description: 'Ideal para começar a conhecer os eixos da BNCC Computação.',
    },
    medio: {
        levelName: 'Médio',
        totalQuestions: 8,
        timePerQuestion: 20,
        lives: 3,
        poolSize: 20,
        description: 'Para quem já conhece os eixos e quer um desafio maior.',
    },
    dificil: {
        levelName: 'Difícil',
        totalQuestions: 12,
        timePerQuestion: 15,
        lives: 2,
        poolSize: 30,
        description: 'Desafio máximo — rápido, muitas questões e poucas chances.',
    },
};

export default function SelectDifficulty() {
    const { setGameConfig } = useGame();
    const navigate = useNavigate();

    function handleSelect(key) {
        setGameConfig(levelConfigs[key]);
        navigate('/game');
    }

    return (
        <div className="difficulty-page">
            <div className="difficulty-container">
                <div className="difficulty-header">
                    <h1>Selecione a Dificuldade</h1>
                    <p className="difficulty-subtitle">Escolha o nível de acordo com seu conhecimento</p>
                </div>

                <div className="levels-grid">
                    {Object.entries(levelConfigs).map(([key, config]) => (
                        <LevelCard
                            key={key}
                            levelKey={key}
                            title={config.levelName}
                            description={config.description}
                            questions={config.totalQuestions}
                            timePerQuestion={config.timePerQuestion}
                            lives={config.lives}
                            onSelect={() => handleSelect(key)}
                        />
                    ))}
                </div>

                <div className="back-btn-wrapper">
                    <button className="btn btn-about" onClick={() => navigate('/')}>
                        Voltar
                    </button>
                </div>
            </div>
        </div>
    );
}

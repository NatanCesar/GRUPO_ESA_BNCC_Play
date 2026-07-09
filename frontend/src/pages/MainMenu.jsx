import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useGame } from '../context/GameContext.jsx';

export default function MainMenu() {
    const [inputValue, setInputValue] = useState('');
    const { setPlayerName } = useGame();
    const navigate = useNavigate();

    function handleStart() {
        const name = inputValue.trim();
        if (!name) {
            alert('Digite seu nome antes de iniciar.');
            return;
        }
        setPlayerName(name);
        navigate('/select-difficulty');
    }

    return (
        <div className="menu-page">
            <div className="menu-container">
                <img src={`${import.meta.env.BASE_URL}logo.png`} alt="BNCC Play" className="logo" />

                <div className="input-group">
                    <label htmlFor="playerName">Nome do jogador</label>
                    <input
                        type="text"
                        id="playerName"
                        placeholder="Ex: Nataniel"
                        value={inputValue}
                        onChange={e => setInputValue(e.target.value)}
                        onKeyDown={e => e.key === 'Enter' && handleStart()}
                    />
                </div>

                <div className="button-group">
                    <button className="btn btn-start" onClick={handleStart}>
                        Jogar
                    </button>
                    <button className="btn btn-join" onClick={() => navigate('/join')}>
                        Entrar em Turma
                    </button>
                    <button className="btn btn-teacher" onClick={() => navigate('/teacher')}>
                        Criar Sala
                    </button>
                    <button className="btn btn-ranking" onClick={() => navigate('/ranking')}>
                        Ranking
                    </button>
                    <button className="btn btn-about" onClick={() => navigate('/about')}>
                        Sobre
                    </button>
                </div>
            </div>
        </div>
    );
}

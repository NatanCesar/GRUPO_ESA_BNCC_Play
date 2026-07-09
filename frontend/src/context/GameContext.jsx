import { createContext, useContext, useState } from 'react';

const GameContext = createContext(null);

export function GameProvider({ children }) {
    const [playerName, setPlayerName] = useState(null);
    const [gameConfig, setGameConfig] = useState(null);
    const [reportData, setReportData] = useState(null);
    const [rankings, setRankings] = useState(() => {
        try {
            return JSON.parse(localStorage.getItem('rankings') || '[]');
        } catch {
            return [];
        }
    });

    // Modo turma
    const [isClassMode, setIsClassMode] = useState(false);
    const [sessionCode, setSessionCode] = useState(null);
    const [playerId, setPlayerId] = useState(null);
    const [questionIndices, setQuestionIndices] = useState(null);
    const [sessionRankings, setSessionRankings] = useState([]);

    function addRankingEntry(entry) {
        setRankings(prev => {
            const updated = [...prev, entry]
                .sort((a, b) => b.score - a.score)
                .slice(0, 10);
            localStorage.setItem('rankings', JSON.stringify(updated));
            return updated;
        });
    }

    function clearRankings() {
        setRankings([]);
        localStorage.removeItem('rankings');
    }

    function resetClassMode() {
        setIsClassMode(false);
        setSessionCode(null);
        setPlayerId(null);
        setQuestionIndices(null);
        setSessionRankings([]);
    }

    return (
        <GameContext.Provider value={{
            playerName, setPlayerName,
            gameConfig, setGameConfig,
            reportData, setReportData,
            rankings, addRankingEntry, clearRankings,
            isClassMode, setIsClassMode,
            sessionCode, setSessionCode,
            playerId, setPlayerId,
            questionIndices, setQuestionIndices,
            sessionRankings, setSessionRankings,
            resetClassMode,
        }}>
            {children}
        </GameContext.Provider>
    );
}

export function useGame() {
    return useContext(GameContext);
}

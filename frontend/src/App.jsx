import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useGame } from './context/GameContext.jsx';
import MainMenu from './pages/MainMenu.jsx';
import SelectDifficulty from './pages/SelectDifficulty.jsx';
import Game from './pages/Game.jsx';
import Report from './pages/Report.jsx';
import Ranking from './pages/Ranking.jsx';
import About from './pages/About.jsx';
import Teacher from './pages/Teacher.jsx';
import JoinSession from './pages/JoinSession.jsx';
import Lobby from './pages/Lobby.jsx';
import ClassRanking from './pages/ClassRanking.jsx';

function ProtectedRoute({ condition, redirectTo, children }) {
    if (!condition) return <Navigate to={redirectTo} replace />;
    return children;
}

function AppRoutes() {
    const { gameConfig, reportData, playerId, isClassMode } = useGame();

    return (
        <Routes>
            <Route path="/" element={<MainMenu />} />
            <Route path="/select-difficulty" element={<SelectDifficulty />} />
            <Route path="/game" element={
                <ProtectedRoute condition={gameConfig !== null} redirectTo="/select-difficulty">
                    <Game />
                </ProtectedRoute>
            } />
            <Route path="/report" element={
                <ProtectedRoute condition={reportData !== null} redirectTo="/">
                    <Report />
                </ProtectedRoute>
            } />
            <Route path="/ranking" element={<Ranking />} />
            <Route path="/about" element={<About />} />
            <Route path="/teacher" element={<Teacher />} />
            <Route path="/join" element={<JoinSession />} />
            <Route path="/lobby" element={
                <ProtectedRoute condition={playerId !== null} redirectTo="/join">
                    <Lobby />
                </ProtectedRoute>
            } />
            <Route path="/class-ranking" element={
                <ProtectedRoute condition={isClassMode} redirectTo="/">
                    <ClassRanking />
                </ProtectedRoute>
            } />
            <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
    );
}

export default function App() {
    return (
        <BrowserRouter basename="/BNCC-Play">
            <AppRoutes />
        </BrowserRouter>
    );
}

import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../services/api.js';
import { connectToSession, disconnectSocket, getSocket } from '../services/socket.js';

const DIFFICULTIES = [
    { key: 'facil',   label: 'Fácil',   desc: '5 questões · 30s · 5 vidas' },
    { key: 'medio',   label: 'Médio',   desc: '8 questões · 20s · 3 vidas' },
    { key: 'dificil', label: 'Difícil', desc: '12 questões · 15s · 2 vidas' },
];

const axisLabels = {
    'pensamento-computacional': 'Pensamento Computacional',
    'mundo-digital': 'Mundo Digital',
    'cultura-digital': 'Cultura Digital',
};

export default function Teacher() {
    const navigate = useNavigate();
    const [view, setView]             = useState('home');   // home | lobby | playing | report
    const [difficulty, setDifficulty] = useState('facil');
    const [session, setSession]       = useState(null);     // { code, sessionId, ... }
    const [players, setPlayers]       = useState([]);
    const [rankings, setRankings]     = useState([]);
    const [report, setReport]         = useState(null);
    const [error, setError]           = useState('');
    const [loading, setLoading]       = useState(false);

    // Socket listeners ao entrar no lobby
    useEffect(() => {
        if (view !== 'lobby' && view !== 'playing') return;
        const socket = getSocket();

        socket.on('session:player_joined', ({ player }) => {
            setPlayers(prev => prev.find(p => p.id === player.id) ? prev : [...prev, player]);
        });
        socket.on('session:player_left', ({ playerId }) => {
            setPlayers(prev => prev.filter(p => p.id !== playerId));
        });
        socket.on('session:ranking_updated', ({ rankings }) => setRankings(rankings));
        socket.on('session:player_finished', () => {});
        socket.on('session:all_finished', ({ rankings }) => {
            setRankings(rankings);
            loadReport();
        });

        return () => {
            socket.off('session:player_joined');
            socket.off('session:player_left');
            socket.off('session:ranking_updated');
            socket.off('session:player_finished');
            socket.off('session:all_finished');
        };
    }, [view]);

    async function handleCreate() {
        setError('');
        setLoading(true);
        try {
            const data = await api.createSession(difficulty);
            setSession(data);
            setPlayers([]);
            connectToSession(data.code, null, 'teacher');
            setView('lobby');
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }

    async function handleStart() {
        setError('');
        setLoading(true);
        try {
            await api.startSession(session.code);
            setView('playing');
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    }

    async function handleEnd() {
        await api.endSession(session.code).catch(() => {});
        await loadReport();
    }

    async function loadReport() {
        try {
            const data = await api.getReport(session.code);
            setReport(data);
            setView('report');
        } catch {}
    }

    function handleReset() {
        disconnectSocket();
        setSession(null);
        setPlayers([]);
        setRankings([]);
        setReport(null);
        setView('home');
    }

    // ── Views ──────────────────────────────────────────────────────────

    if (view === 'home') return (
        <div className="menu-page">
            <div className="menu-container" style={{ maxWidth: '480px' }}>
                <h1 className="page-title">Painel do Professor</h1>

                {error && <p className="error-msg">{error}</p>}

                <p style={{ color: '#94a3b8', marginBottom: '12px' }}>Selecione a dificuldade:</p>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '20px' }}>
                    {DIFFICULTIES.map(d => (
                        <label key={d.key} style={{
                            display: 'flex', alignItems: 'center', gap: '12px',
                            background: difficulty === d.key ? 'rgba(56,189,248,0.12)' : 'rgba(15,23,42,0.5)',
                            border: `2px solid ${difficulty === d.key ? '#38bdf8' : '#334155'}`,
                            borderRadius: '8px', padding: '12px 16px', cursor: 'pointer',
                        }}>
                            <input type="radio" name="diff" value={d.key}
                                checked={difficulty === d.key}
                                onChange={() => setDifficulty(d.key)}
                                style={{ accentColor: '#38bdf8' }}
                            />
                            <div>
                                <strong>{d.label}</strong>
                                <span style={{ color: '#94a3b8', fontSize: '0.85rem', marginLeft: '8px' }}>{d.desc}</span>
                            </div>
                        </label>
                    ))}
                </div>

                <div className="button-group">
                    <button className="btn btn-teacher" onClick={handleCreate} disabled={loading}>
                        {loading ? 'Criando...' : 'Criar Sessão'}
                    </button>
                    <button className="btn btn-about" onClick={() => navigate('/')}>
                        Voltar
                    </button>
                </div>
            </div>
        </div>
    );

    if (view === 'lobby') return (
        <div className="menu-page">
            <div className="menu-container" style={{ maxWidth: '540px' }}>
                <h1 className="page-title">Sala de Espera</h1>
                <p style={{ color: '#94a3b8', marginBottom: '4px' }}>Código para os alunos:</p>
                <p style={{ fontSize: '3rem', fontWeight: 'bold', letterSpacing: '0.35em', color: '#38bdf8', marginBottom: '8px' }}>
                    {session.code}
                </p>
                <p style={{ color: '#475569', fontSize: '0.85rem', marginBottom: '24px' }}>
                    {session.levelName} · {session.totalQuestions} questões · {session.timePerQuestion}s · {session.lives} vidas
                </p>

                {error && <p className="error-msg">{error}</p>}

                <div style={{ textAlign: 'left', width: '100%', marginBottom: '24px' }}>
                    <p style={{ fontWeight: 'bold', marginBottom: '8px' }}>
                        Alunos conectados ({players.length}):
                    </p>
                    {players.length === 0
                        ? <p style={{ color: '#475569' }}>Aguardando alunos...</p>
                        : <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '6px' }}>
                            {players.map(p => (
                                <li key={p.id} style={{ background: 'rgba(56,189,248,0.08)', border: '1px solid #334155', borderRadius: '6px', padding: '8px 12px' }}>
                                    {p.name}
                                </li>
                            ))}
                        </ul>
                    }
                </div>

                <div className="button-group">
                    <button className="btn primary" onClick={handleStart} disabled={loading || players.length === 0}>
                        {loading ? 'Iniciando...' : `Iniciar Jogo (${players.length} aluno${players.length !== 1 ? 's' : ''})`}
                    </button>
                </div>
            </div>
        </div>
    );

    if (view === 'playing') return (
        <main className="ranking-page">
            <div className="ranking-container">
                <div className="ranking-header">
                    <h1 className="ranking-title">Acompanhamento ao Vivo</h1>
                    <div className="ranking-status ranking-status--live">
                        <span className="live-dot" /> <span>Jogo em andamento</span>
                    </div>
                </div>

                <div className="teacher-session-info">
                    <span>{session.levelName}</span>
                    <span>{session.totalQuestions} questões</span>
                    <span>{session.timePerQuestion}s por questão</span>
                    <span>{session.lives} vidas</span>
                </div>

                <div className="ranking-table-wrap" style={{ marginBottom: '24px' }}>
                    <table className="ranking-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Aluno</th>
                                <th>Pts</th>
                                <th>Acerto</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            {rankings.map(r => (
                                <tr key={r.playerId} className="ranking-row">
                                    <td className="ranking-pos">{r.position}</td>
                                    <td className="ranking-name">
                                        <span className="ranking-name-inner">{r.name}</span>
                                    </td>
                                    <td className="ranking-pts">{r.score}</td>
                                    <td className="ranking-acc">{r.accuracy}%</td>
                                    <td className="ranking-status-cell">
                                        {r.status === 'FINISHED'
                                            ? <span className="status-done">✓</span>
                                            : <span className="status-playing">▶</span>
                                        }
                                    </td>
                                </tr>
                            ))}
                            {rankings.length === 0 && (
                                <tr>
                                    <td colSpan={5} className="ranking-empty">Aguardando respostas...</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                <button className="btn secondary ranking-btn-leave" onClick={handleEnd}>
                    Encerrar Sessão
                </button>
            </div>
        </main>
    );

    if (view === 'report' && report) return (
        <main className="ranking-page">
            <div className="ranking-container">
                <div className="ranking-header">
                    <h1 className="ranking-title">Relatório da Turma</h1>
                    <p className="ranking-subtitle">
                        {report.levelName} · {report.totalPlayers} aluno{report.totalPlayers !== 1 ? 's' : ''}
                    </p>
                </div>

                {/* Média da turma */}
                <div className="teacher-avg-card">
                    <div className="teacher-avg-card__col">
                        <span className="teacher-avg-card__label">Média de pontos</span>
                        <span className="teacher-avg-card__val">{report.classAverage.score} <small>pts</small></span>
                    </div>
                    <div className="teacher-avg-card__divider" />
                    <div className="teacher-avg-card__col">
                        <span className="teacher-avg-card__label">Taxa de acerto</span>
                        <span className="teacher-avg-card__val">{report.classAverage.accuracy}<small>%</small></span>
                    </div>
                </div>

                {/* Cards por aluno */}
                <div className="teacher-players">
                    {report.players.map((p, i) => (
                        <div key={i} className="teacher-player-card">
                            <div className="teacher-player-card__header">
                                <span className="teacher-player-card__name">{p.name}</span>
                                <span className="teacher-player-card__score">{p.score} pts · {p.accuracy}%</span>
                            </div>
                            <div className="teacher-category-grid">
                                {Object.entries(p.byCategory).map(([axis, stats]) => {
                                    const isEmpty = stats.total === 0;
                                    const isAll   = !isEmpty && stats.correct === stats.total;
                                    const isNone  = !isEmpty && stats.correct === 0;
                                    return (
                                        <div
                                            key={axis}
                                            className={`teacher-cat${isEmpty ? ' teacher-cat--empty' : isAll ? ' teacher-cat--ok' : isNone ? ' teacher-cat--fail' : ' teacher-cat--partial'}`}
                                        >
                                            <span className="teacher-cat__axis">{axisLabels[axis]}</span>
                                            <span className="teacher-cat__score">{stats.correct}/{stats.total}</span>
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                    ))}
                </div>

                <div style={{ display: 'flex', gap: '10px', marginTop: '0' }}>
                    <button className="btn primary ranking-btn-leave" onClick={handleReset}>
                        Nova Sessão
                    </button>
                    <button className="btn secondary ranking-btn-leave" onClick={() => { disconnectSocket(); navigate('/'); }}>
                        Menu Principal
                    </button>
                </div>
            </div>
        </main>
    );

    return null;
}

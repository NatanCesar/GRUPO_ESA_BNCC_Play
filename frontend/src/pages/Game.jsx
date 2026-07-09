import { useReducer, useEffect, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useGame } from '../context/GameContext.jsx';
import { allQuestions } from '../data/questions.js';
import { api } from '../services/api.js';
import HUD from '../components/HUD.jsx';
import TimerBar from '../components/TimerBar.jsx';
import QuestionCard from '../components/QuestionCard.jsx';
import DropZone from '../components/DropZone.jsx';
import FeedbackModal from '../components/FeedbackModal.jsx';

const axisLabels = {
    'pensamento-computacional': 'Pensamento Computacional',
    'mundo-digital': 'Mundo Digital',
    'cultura-digital': 'Cultura Digital',
};

const dropZones = [
    { axis: 'pensamento-computacional', label: 'Pensamento Computacional' },
    { axis: 'mundo-digital',            label: 'Mundo Digital' },
    { axis: 'cultura-digital',          label: 'Cultura Digital' },
];

function shuffle(array) {
    const arr = [...array];
    for (let i = arr.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
}

function buildInitialState(config, orderedQuestions) {
    return {
        score: 0,
        lives: config.lives,
        remainingQuestions: config.totalQuestions,
        timeLeft: config.timePerQuestion,
        currentQuestion: null,
        shuffledQuestions: orderedQuestions
            || shuffle(allQuestions.slice(0, config.poolSize || allQuestions.length)),
        questionIndex: 0,
        feedback: null,       // { isCorrect, title, message, reason }
        gameOver: false,
        resetSignal: 0,       // incrementado a cada nova questão para resetar TimerBar
        answersLog: [],       // respostas acumuladas para envio no modo turma
    };
}

function reducer(state, action) {
    switch (action.type) {
        case 'LOAD_QUESTION': {
            let { shuffledQuestions, questionIndex } = state;
            if (questionIndex >= shuffledQuestions.length) {
                shuffledQuestions = shuffle(shuffledQuestions);
                questionIndex = 0;
            }
            const currentQuestion = shuffledQuestions[questionIndex];
            return {
                ...state,
                currentQuestion,
                shuffledQuestions,
                questionIndex: questionIndex + 1,
                remainingQuestions: state.remainingQuestions - 1,
                timeLeft: action.timePerQuestion,
                feedback: null,
                resetSignal: state.resetSignal + 1,
            };
        }
        case 'TICK':
            return { ...state, timeLeft: state.timeLeft - 1 };
        case 'CORRECT_ANSWER':
            return {
                ...state,
                score: state.score + 100,
                answersLog: [...state.answersLog, {
                    questionIndex: action.questionIndex,
                    chosenAxis: action.chosenAxis,
                    correctAxis: state.currentQuestion.axis,
                    isCorrect: true,
                    timeSpent: action.timeSpent,
                }],
                feedback: {
                    isCorrect: true,
                    title: 'Boa decisão!',
                    message: `Essa situação pertence ao eixo ${axisLabels[state.currentQuestion.axis]}.`,
                    reason: state.currentQuestion.reason,
                },
            };
        case 'WRONG_ANSWER':
            return {
                ...state,
                lives: state.lives - 1,
                answersLog: [...state.answersLog, {
                    questionIndex: action.questionIndex,
                    chosenAxis: action.chosenAxis ?? null,
                    correctAxis: state.currentQuestion.axis,
                    isCorrect: false,
                    timeSpent: action.timeSpent,
                }],
                feedback: {
                    isCorrect: false,
                    title: 'Atenção!',
                    message: `O eixo correto era ${axisLabels[state.currentQuestion.axis]}.`,
                    reason: state.currentQuestion.reason,
                },
            };
        case 'CLOSE_FEEDBACK':
            return { ...state, feedback: null };
        case 'END_GAME':
            return { ...state, gameOver: true };
        default:
            return state;
    }
}

export default function Game() {
    const { gameConfig, setReportData, addRankingEntry, playerName,
            isClassMode, playerId, sessionCode, questionIndices, setSessionRankings } = useGame();
    const navigate = useNavigate();

    const orderedQuestions = questionIndices ? questionIndices.map(i => allQuestions[i]) : null;
    const [state, dispatch] = useReducer(reducer, null, () => buildInitialState(gameConfig, orderedQuestions));
    const timerRef = useRef(null);
    const questionCardRef = useRef(null);
    const touchCloneRef = useRef(null);

    const { score, lives, remainingQuestions, timeLeft, currentQuestion, feedback, gameOver, resetSignal, answersLog, questionIndex } = state;

    // Carrega primeira questão (ref evita duplo disparo do StrictMode em dev)
    const initialLoadDone = useRef(false);
    useEffect(() => {
        if (initialLoadDone.current) return;
        initialLoadDone.current = true;
        dispatch({ type: 'LOAD_QUESTION', timePerQuestion: gameConfig.timePerQuestion });
    }, [gameConfig.timePerQuestion]);

    // Timer
    useEffect(() => {
        if (!currentQuestion || feedback || gameOver) return;
        timerRef.current = setInterval(() => {
            dispatch({ type: 'TICK' });
        }, 1000);
        return () => clearInterval(timerRef.current);
    }, [currentQuestion, feedback, gameOver, resetSignal]);

    // Timeout
    useEffect(() => {
        if (timeLeft <= 0 && currentQuestion && !feedback) {
            clearInterval(timerRef.current);
            const currentQuestionIndex = (questionIndices ?? [])[questionIndex - 1] ?? (questionIndex - 1);
            dispatch({ type: 'WRONG_ANSWER', chosenAxis: null, questionIndex: currentQuestionIndex, timeSpent: gameConfig.timePerQuestion });
        }
    }, [timeLeft, currentQuestion, feedback]);

    // Fim de jogo — só dispara quando não há feedback pendente
    useEffect(() => {
        if (gameOver || feedback) return;
        if (lives <= 0 || (remainingQuestions <= 0 && !currentQuestion)) {
            dispatch({ type: 'END_GAME' });
        }
    }, [lives, remainingQuestions, feedback, currentQuestion, gameOver]);

    useEffect(() => {
        if (!gameOver) return;
        const totalAnswered = gameConfig.totalQuestions - remainingQuestions;
        const correctAnswers = score / 100;
        const accuracy = totalAnswered > 0 ? Math.round((correctAnswers / totalAnswered) * 100) : 0;
        const data = { score, totalAnswered, correctAnswers, levelName: gameConfig.levelName };
        setReportData(data);

        if (isClassMode && playerId) {
            api.finishPlayer(playerId, {
                score,
                livesLeft: lives,
                correctAnswers,
                totalAnswered,
                answers: answersLog,
            }).then(res => {
                if (res.rankings) setSessionRankings(res.rankings);
            }).catch(() => {});
            navigate('/class-ranking');
        } else {
            addRankingEntry({
                name: playerName || 'Anônimo',
                score,
                levelName: gameConfig.levelName,
                accuracy,
                date: new Date().toLocaleDateString('pt-BR'),
            });
            navigate('/report');
        }
    }, [gameOver]);

    // Resposta via drop
    const handleDrop = useCallback((axis) => {
        if (!currentQuestion || feedback) return;
        clearInterval(timerRef.current);
        const timeSpent = gameConfig.timePerQuestion - timeLeft;
        const currentQuestionIndex = (questionIndices ?? [])[questionIndex - 1] ?? (questionIndex - 1);
        if (axis === currentQuestion.axis) {
            dispatch({ type: 'CORRECT_ANSWER', chosenAxis: axis, questionIndex: currentQuestionIndex, timeSpent });
        } else {
            dispatch({ type: 'WRONG_ANSWER', chosenAxis: axis, questionIndex: currentQuestionIndex, timeSpent });
        }
    }, [currentQuestion, feedback, timeLeft, gameConfig.timePerQuestion, questionIndex, questionIndices]);

    // Continuar após feedback
    function handleContinue() {
        if (lives <= 0 || remainingQuestions <= 0) {
            dispatch({ type: 'END_GAME' });
        } else {
            dispatch({ type: 'LOAD_QUESTION', timePerQuestion: gameConfig.timePerQuestion });
        }
    }

    // Touch support
    useEffect(() => {
        const card = questionCardRef.current;
        if (!card || !currentQuestion) return;

        let offsetX = 0;
        let offsetY = 0;

        function onTouchStart(e) {
            if (!currentQuestion) return;
            e.preventDefault();
            const touch = e.touches[0];
            const rect = card.getBoundingClientRect();
            offsetX = touch.clientX - rect.left;
            offsetY = touch.clientY - rect.top;

            const clone = card.cloneNode(true);
            clone.style.position = 'fixed';
            clone.style.width = rect.width + 'px';
            clone.style.zIndex = '9999';
            clone.style.opacity = '0.85';
            clone.style.pointerEvents = 'none';
            clone.style.margin = '0';
            clone.style.left = (touch.clientX - offsetX) + 'px';
            clone.style.top = (touch.clientY - offsetY) + 'px';
            document.body.appendChild(clone);
            touchCloneRef.current = clone;
        }

        function onTouchMove(e) {
            if (!touchCloneRef.current) return;
            e.preventDefault();
            const touch = e.touches[0];
            touchCloneRef.current.style.left = (touch.clientX - offsetX) + 'px';
            touchCloneRef.current.style.top = (touch.clientY - offsetY) + 'px';

            document.querySelectorAll('.drop-zone').forEach(z => z.classList.remove('drag-over'));
            touchCloneRef.current.style.display = 'none';
            const el = document.elementFromPoint(touch.clientX, touch.clientY);
            touchCloneRef.current.style.display = '';
            const zone = el?.closest('.drop-zone');
            if (zone) zone.classList.add('drag-over');
        }

        function onTouchEnd(e) {
            if (!touchCloneRef.current) return;
            const touch = e.changedTouches[0];
            document.querySelectorAll('.drop-zone').forEach(z => z.classList.remove('drag-over'));
            touchCloneRef.current.style.display = 'none';
            const el = document.elementFromPoint(touch.clientX, touch.clientY);
            touchCloneRef.current.remove();
            touchCloneRef.current = null;

            const zone = el?.closest('.drop-zone');
            if (zone) handleDrop(zone.dataset.axis);
        }

        card.addEventListener('touchstart', onTouchStart, { passive: false });
        document.addEventListener('touchmove', onTouchMove, { passive: false });
        document.addEventListener('touchend', onTouchEnd);

        return () => {
            card.removeEventListener('touchstart', onTouchStart);
            document.removeEventListener('touchmove', onTouchMove);
            document.removeEventListener('touchend', onTouchEnd);
        };
    }, [currentQuestion, handleDrop]);

    if (!currentQuestion) return null;

    const questionNumber = gameConfig.totalQuestions - remainingQuestions;

    return (
        <main className="game-container">
            <HUD
                levelName={gameConfig.levelName}
                questionProgress={`${questionNumber} de ${gameConfig.totalQuestions}`}
                timeLeft={timeLeft}
                score={score}
                lives={lives}
            />

            <TimerBar
                timeLeft={timeLeft}
                totalTime={gameConfig.timePerQuestion}
                resetSignal={resetSignal}
            />

            <section className="question-area">
                <QuestionCard ref={questionCardRef} text={currentQuestion.text} />
            </section>

            <section className="axes-area">
                {dropZones.map(({ axis, label }) => (
                    <DropZone key={axis} axis={axis} label={label} onDrop={handleDrop} />
                ))}
            </section>

            {feedback && (
                <FeedbackModal
                    visible={true}
                    isCorrect={feedback.isCorrect}
                    title={feedback.title}
                    message={feedback.message}
                    reason={feedback.reason}
                    onContinue={handleContinue}
                />
            )}
        </main>
    );
}

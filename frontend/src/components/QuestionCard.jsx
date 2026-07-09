import { forwardRef } from 'react';

const QuestionCard = forwardRef(function QuestionCard({ text }, ref) {
    return (
        <div className="question-card" draggable="true" ref={ref} id="questionCard">
            <span className="question-card-label">Situação</span>
            <p>{text}</p>
            <span className="question-card-hint">Arraste para o eixo correto</span>
        </div>
    );
});

export default QuestionCard;

import { useNavigate } from 'react-router-dom';

export default function About() {
    const navigate = useNavigate();

    return (
        <div className="about-page">
            <div className="about-container">
                <div className="about-header">
                    <h1>BNCC Play</h1>
                    <p className="tagline">Aprendendo Computação com a BNCC</p>
                </div>

                <div className="about-section">
                    <h2>Sobre o Projeto</h2>
                    <p>
                        BNCC Play é uma plataforma educacional gamificada de apoio ao ensino de
                        Computação na Educação Básica, alinhada às diretrizes da BNCC Computação.
                        De forma prática e divertida, os alunos exploram os três eixos da área:
                        Pensamento Computacional, Mundo Digital e Cultura Digital.
                    </p>
                </div>

                <div className="about-section">
                    <h2>Como Jogar</h2>
                    <p>
                        Situações do dia a dia aparecem na tela e você deve arrastá-las para o
                        eixo correto da BNCC Computação: Pensamento Computacional, Mundo Digital
                        ou Cultura Digital. Cada acerto aumenta sua pontuação. Erros custam vidas!
                        Professores também podem criar salas para jogar com a turma em tempo real.
                    </p>
                </div>

                <div className="about-section">
                    <h2>Autores</h2>
                    <ul>
                        <li>Nataniel Cesar da Silva</li>
                        <li>Diogo Mendonça de Almeida Oliveira</li>
                        <li>Fernanda Rodrigues da Silva</li>
                        <li>Gustavo Coutinho Soares</li>
                        <li>Luiz Gustavo dos Santos Silva</li>
                        <li>Marcos Antonio Jose da Silva</li>
                    </ul>
                </div>

                <div className="about-section">
                    <h2>Instituição</h2>
                    <p>Universidade Federal da Paraíba (UFPB) — Campus IV, Rio Tinto, 2026</p>
                    <p>Engenharia de Software Aplicada — Licenciatura Ciência da Computação</p>
                </div>

                <button className="btn btn-about btn-back" onClick={() => navigate('/')}>
                    Voltar ao Menu
                </button>
            </div>
        </div>
    );
}

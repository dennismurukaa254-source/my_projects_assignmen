`javascript
// ===== LOADING SCREEN =====
window.addEventListener('load', () => {
document.getElementById('loader').classList.add('hidden');
});
// ===== THEME TOGGLE =====
const themeToggle = document.getElementById('themeToggle');
const currentTheme = localStorage.getItem('theme') || 'dark';
document.documentElement.setAttribute('data-theme', currentTheme);
updateThemeIcon(currentTheme);
themeToggle.addEventListener('click', () => {
const theme = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
document.documentElement.setAttribute('data-theme', theme);
localStorage.setItem('theme', theme);
updateThemeIcon(theme);
});
function updateThemeIcon(theme) {
const icon = themeToggle.querySelector('i');
icon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun';
}
// ===== TYPING EFFECT =====
const typingElement = document.getElementById('typingText');
const words = ['Software Developer', 'IT Student', 'Cybersecurity Enthusiast'];
let wordIndex = 0;
let charIndex = 0;
let isDeleting = false;
function typeEffect() {
const currentWord = words[wordIndex];
if (isDeleting) {
typingElement.textContent = currentWord.substring(0, charIndex - 1);
charIndex--;
} else {
typingElement.textContent = currentWord.substring(0, charIndex + 1);
charIndex++;
}
if (!isDeleting && charIndex === currentWord.length) {
setTimeout(() => { isDeleting = true; typeEffect(); }, 2000);
return;
}
if (isDeleting && charIndex === 0) {
isDeleting = false;
wordIndex = (wordIndex + 1) % words.length;
setTimeout(typeEffect, 500);
return;
}
setTimeout(typeEffect, isDeleting ? 50 : 100);
}
typeEffect();
// ===== SCROLL REVEAL (Intersection Observer) =====
const observerOptions = { threshold: 0.1, rootMargin: '0px 0px -50px 0px' };
const observer = new IntersectionObserver((entries) => {
entries.forEach(entry => {
if (entry.isIntersecting) {
entry.target.classList.add('visible');
}
});
}, observerOptions);
document.querySelectorAll('.glass, .project-card, .skill-category, .stat-card, .about-card').forEach(el => {
el.classList.add('fade-in');
observer.observe(el);
});
// ===== GITHUB API =====
const GITHUBUSERNAME = 'DennisMuruka'; // Change to your actual username
async function fetchGitHubStats() {
try {
const res = await fetch(https://api.github.com/users/${GITHUBUSERNAME});
const data = await res.json();
animateNumber('repoCount', data.publicrepos || 0);
animateNumber('followerCount', data.followers || 0);
animateNumber('followingCount', data.following || 0);
// Fetch repos
const reposRes = await fetch(https://api.github.com/users/${GITHUBUSERNAME}/repos?sort=updated&perpage=6);
const repos = await reposRes.json();
const reposContainer = document.getElementById('githubRepos');
reposContainer.innerHTML = '';
repos.forEach(repo => {
const card = document.createElement('div');
card.className = 'repo-card glass';
card.innerHTML =
${repo.name}

${repo.description || 'No description'}



⭐ ${repo.stargazers
count}
🍴 ${repo.forkscount}


View on GitHub
`;
reposContainer.appendChild(card);
});
} catch (err) {
console.warn('GitHub API error – using fallback data.');
document.getElementById('repoCount').textContent = '8';
document.getElementById('followerCount').textContent = '12';
document.getElementById('followingCount').textContent = '20';
document.getElementById('githubRepos').innerHTML = '
Unable to load repositories. Please refresh or check your internet.

';
}
}
function animateNumber




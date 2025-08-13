// Script à injecter dans le dashboard Traefik pour ajouter des liens
(function() {
    'use strict';
    
    // Attendre que la page soit chargée
    function addMonitoringLinks() {
        // Vérifier si les liens n'ont pas déjà été ajoutés
        if (document.getElementById('monitoring-links')) {
            return;
        }
        
        // Créer le conteneur des liens
        const linksContainer = document.createElement('div');
        linksContainer.id = 'monitoring-links';
        linksContainer.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 10000;
            background: rgba(0, 0, 0, 0.9);
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            font-family: Arial, sans-serif;
            min-width: 200px;
        `;
        
        // Titre
        const title = document.createElement('h3');
        title.textContent = '🚀 TUVCB Monitoring';
        title.style.cssText = `
            color: #00d4ff;
            margin: 0 0 10px 0;
            font-size: 14px;
            text-align: center;
        `;
        linksContainer.appendChild(title);
        
        // Configuration des liens
        const links = [
            { name: '📊 Grafana', url: 'http://localhost:3001', desc: 'Dashboards' },
            { name: '🔍 Prometheus', url: 'http://localhost:9090', desc: 'Métriques' },
            { name: '🏠 Hub Monitoring', url: 'http://monitoring.localhost', desc: 'Central' },
            { name: '🔧 Consul', url: 'http://localhost:8500', desc: 'Services' },
            { name: '💻 Node Exporter', url: 'http://localhost:9100', desc: 'Système' },
            { name: '🐳 cAdvisor', url: 'http://localhost:8081', desc: 'Conteneurs' }
        ];
        
        // Créer les liens
        links.forEach(link => {
            const linkElement = document.createElement('a');
            linkElement.href = link.url;
            linkElement.target = '_blank';
            linkElement.style.cssText = `
                display: block;
                color: #ffffff;
                text-decoration: none;
                padding: 8px 12px;
                margin: 2px 0;
                border: 1px solid #333;
                border-radius: 4px;
                background: #1a1a1a;
                transition: all 0.3s ease;
                font-size: 12px;
                line-height: 1.2;
            `;
            
            linkElement.innerHTML = `
                <strong>${link.name}</strong><br>
                <small style="opacity: 0.7;">${link.desc}</small>
            `;
            
            // Effet hover
            linkElement.addEventListener('mouseenter', function() {
                this.style.background = '#00d4ff';
                this.style.color = '#000';
                this.style.borderColor = '#00d4ff';
            });
            
            linkElement.addEventListener('mouseleave', function() {
                this.style.background = '#1a1a1a';
                this.style.color = '#ffffff';
                this.style.borderColor = '#333';
            });
            
            linksContainer.appendChild(linkElement);
        });
        
        // Bouton pour masquer/afficher
        const toggleButton = document.createElement('button');
        toggleButton.textContent = '−';
        toggleButton.style.cssText = `
            position: absolute;
            top: 5px;
            right: 5px;
            background: none;
            border: none;
            color: #ccc;
            font-size: 16px;
            cursor: pointer;
            width: 20px;
            height: 20px;
            text-align: center;
            line-height: 1;
        `;
        
        let isCollapsed = false;
        toggleButton.addEventListener('click', function() {
            isCollapsed = !isCollapsed;
            const linkElements = linksContainer.querySelectorAll('a, h3');
            linkElements.forEach(el => {
                el.style.display = isCollapsed ? 'none' : (el.tagName === 'A' ? 'block' : 'block');
            });
            this.textContent = isCollapsed ? '+' : '−';
        });
        
        linksContainer.appendChild(toggleButton);
        
        // Ajouter à la page
        document.body.appendChild(linksContainer);
        
        console.log('🚀 TUVCB Monitoring links added to Traefik dashboard');
    }
    
    // Vérifier périodiquement si on peut ajouter les liens
    function checkAndAdd() {
        if (document.body) {
            addMonitoringLinks();
        } else {
            setTimeout(checkAndAdd, 500);
        }
    }
    
    // Démarrer la vérification
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', checkAndAdd);
    } else {
        checkAndAdd();
    }
})();

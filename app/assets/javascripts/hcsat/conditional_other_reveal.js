class ConditionalOtherReveal {
    constructor(checkBoxId, ConditionalRevealContainerId) {
        this.checkBox = document.getElementById(checkBoxId);
        this.conditionalRevealContainer = document.getElementById(ConditionalRevealContainerId)
        this.conditionalRevealContainer.classList.add('hidden')
    }

    initializeEventListeners() {
        console.log('clicked')
        textArea = document.getElementById('feedback_service_improvements_feedback')
        this.textArea.addEventListener('input', async (event ) => {
            console.log('textarea changed')
        })
        this.checkBox.addEventListener('onClick', async (event) => {
            
            this.conditionalRevealContainer.classList.remove('hidden')
        })
    }
}
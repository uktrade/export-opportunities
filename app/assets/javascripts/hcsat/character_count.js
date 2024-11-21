class HCSATCharacterCount {
    constructor(textAreaId, characterCounterId) {
        this.textArea = document.getElementById(textAreaId)   
        this.characterCounter = document.getElementById(characterCounterId)   
    }

    initialiseCharacterCount() {
        this.textArea.addEventListener('keyup', async (event ) => {
            var currentCount = this.textArea.value.length

            if (currentCount < 1201) {
                console.log(this.characterCounter.classList)
                if (this.characterCounter.classList.contains('hcsat__error')) {
                    this.characterCounter.classList.remove('hcsat__error')
                }
                this.characterCounter.innerHTML = "You have " + (1200 - currentCount)+" characters remaining"
            } else {
                if (!(this.characterCounter.classList.contains('hcsat__error'))) {
                    this.characterCounter.classList.add('hcsat__error')
                }
                this.characterCounter.innerHTML = "You have " + Math.abs(1200 - currentCount)+" characters too many"
            }

            
    })
}
}   

document.addEventListener('DOMContentLoaded', () => {
    HCSATCharacterCount = new HCSATCharacterCount('feedback_service_improvements_feedback', 'character_counter');
    HCSATCharacterCount.initialiseCharacterCount()
});
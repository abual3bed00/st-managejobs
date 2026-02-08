const playerIdInput = document.getElementById('player-id');

const jobList = document.getElementById('job-list');
const jobGradeList = document.getElementById('job-grade-list');

const gangList = document.getElementById('gang-list');
const gangGradeList = document.getElementById('gang-grade-list');

const assignJobBtn = document.getElementById('assign-job');
const assignGangBtn = document.getElementById('assign-gang');

const closeBtn = document.getElementById('close-btn');

function clearSelectOptions(select) {
  select.innerHTML = '<option value="" disabled selected>اختر</option>';
}

function setSelectDisabled(select, disabled) {
  select.disabled = disabled;
}

// استقبال بيانات الوظائف والعصابات من السيرفر وملء القوائم
function fetchData() {
  fetch(`https://${GetParentResourceName()}/getData`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  })
    .then(resp => resp.json())
    .then(data => {
      if (data.jobs) {
        clearSelectOptions(jobList);
        data.jobs.forEach(job => {
          const opt = document.createElement('option');
          opt.value = job.name;
          opt.textContent = job.label;
          jobList.appendChild(opt);
        });
      }
      if (data.gangs) {
        clearSelectOptions(gangList);
        data.gangs.forEach(gang => {
          const opt = document.createElement('option');
          opt.value = gang.name;
          opt.textContent = gang.label;
          gangList.appendChild(opt);
        });
      }
      setSelectDisabled(jobGradeList, true);
      setSelectDisabled(gangGradeList, true);
    });
}

// جلب رتب الوظيفة حسب الاختيار
jobList.addEventListener('change', () => {
  const selectedJob = jobList.value;
  if (!selectedJob) {
    clearSelectOptions(jobGradeList);
    setSelectDisabled(jobGradeList, true);
    return;
  }
  fetch(`https://${GetParentResourceName()}/getJobGrades`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ job: selectedJob }),
  })
    .then(resp => resp.json())
    .then(data => {
      clearSelectOptions(jobGradeList);
      if (data.grades && data.grades.length > 0) {
        data.grades.forEach(grade => {
          const opt = document.createElement('option');
          opt.value = grade.grade;
          opt.textContent = grade.name;
          jobGradeList.appendChild(opt);
        });
        setSelectDisabled(jobGradeList, false);
      } else {
        setSelectDisabled(jobGradeList, true);
      }
    });
});

// جلب رتب العصابة حسب الاختيار
gangList.addEventListener('change', () => {
  const selectedGang = gangList.value;
  if (!selectedGang) {
    clearSelectOptions(gangGradeList);
    setSelectDisabled(gangGradeList, true);
    return;
  }
  fetch(`https://${GetParentResourceName()}/getGangGrades`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ gang: selectedGang }),
  })
    .then(resp => resp.json())
    .then(data => {
      clearSelectOptions(gangGradeList);
      if (data.grades && data.grades.length > 0) {
        data.grades.forEach(grade => {
          const opt = document.createElement('option');
          opt.value = grade.grade;
          opt.textContent = grade.name;
          gangGradeList.appendChild(opt);
        });
        setSelectDisabled(gangGradeList, false);
      } else {
        setSelectDisabled(gangGradeList, true);
      }
    });
});

// تعيين وظيفة
assignJobBtn.addEventListener('click', () => {
  const playerId = parseInt(playerIdInput.value);
  const job = jobList.value;
  const grade = parseInt(jobGradeList.value);

  if (!playerId || !job || isNaN(grade)) {
    console.log ("Please enter the player ID, job, and grade correctly.");
    return;
  }

  fetch(`https://${GetParentResourceName()}/assignJob`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id: playerId, job: job, grade: grade }),
  });
});

// تعيين عصابة
assignGangBtn.addEventListener('click', () => {
  const playerId = parseInt(playerIdInput.value);
  const gang = gangList.value;
  const grade = parseInt(gangGradeList.value);

  if (!playerId || !gang || isNaN(grade)) {
    alert('يرجى تعبئة رقم اللاعب والعصابة والرتبة بشكل صحيح.');
    return;
  }

  fetch(`https://${GetParentResourceName()}/assignGang`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id: playerId, gang: gang, grade: grade }),
  });
});

// زر إغلاق الواجهة
closeBtn.addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/close`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({}),
  });
});

// استقبال أمر إظهار/إخفاء الواجهة من السيرفر
window.addEventListener('message', (event) => {
  if (event.data.action === 'toggleUI') {
    console.log('Toggle UI message received:', event.data.show);
    const container = document.querySelector('.manager-container');
    if (event.data.show) {
      container.classList.add('active');
      fetchData();
    } else {
      container.classList.remove('active');
    }
  }
});

document.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') {
    // إخفاء الواجهة
    const container = document.querySelector('.manager-container');
    container.classList.remove('active');

    // إرسال حدث للسيرفر لإغلاق الواجهة
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({}),
    });
  }
});

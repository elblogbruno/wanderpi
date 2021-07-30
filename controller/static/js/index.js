function deleteVideo(id){
    console.log(id);
}

function shareVideo(id){

    if (navigator.share) {
          navigator.share({
            title: 'WebShare API Demo',
            url: 'https://codepen.io/ayoisaiah/pen/YbNazJ'
          }).then(() => {
            console.log('Thanks for sharing!');
          })
          .catch(console.error);
        } else {
          // fallback
        }
}
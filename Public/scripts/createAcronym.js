$.ajax({
       url: "/api/categories/",
       type: "GET",
       contentType: "application/json; charset=utf-8"
       }).then(function (response) {
               var dataToReturn = [];

               for (var i=0; i < response.length; i++) {
               var tatToTransform = response[i];
               var newTag = {
               id: tatToTransform["name"],
               text: tatToTransform["name"]
               };
               dataToReturn.push(newTag);
               }

               $("#categories").select2({
                                        placeholder: "Select Categories for the Acronym",
                                        tags: true,
                                        tokenSeperators: ['.'],
                                        data: dataToReturn
                                        });
               });

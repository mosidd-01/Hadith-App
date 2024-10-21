//
//  ContentView.swift
//  Hadith App
//
//  Created by Muhammad Siddiqui on 10/19/24.
//

import SwiftUI

struct ContentView: View {
    var hadith: String = "حدثنا الحميدي عبد الله بن الزبير، قال حدثنا سفيان، قال حدثنا يحيى بن سعيد الأنصاري، قال أخبرني محمد بن إبراهيم التيمي، أنه سمع علقمة بن وقاص الليثي، يقول سمعت عمر بن الخطاب  رضى الله عنه  على المنبر قال سمعت رسول الله صلى الله عليه وسلم يقول ‏\"‏ إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى، فمن كانت هجرته إلى دنيا يصيبها أو إلى امرأة ينكحها فهجرته إلى ما هاجر إليه ‏\"‏‏.‏"
    
    var body: some View {
        VStack {
            Text("Hadith App")
            Button("Test Hadith Loading") {
                testHadithLoading()
            }
        }
        .onAppear {
            // This will trigger the loading of hadiths when the view appears
            let _ = HadithStore.hadiths
            let _ = RawiStore.rawis
        }
    }
}

#Preview {
    ContentView()
}
